// v001 11/10/2024

	//	To implement the required concurrent functionality, your JobManager must use two Extrinsic Monitor classes:
	//			java.util.concurrent.locks.Condition;
	//			java.util.concurrent.locks.ReentrantLock;
	//	Note that you must not use the signalAll() method (as this creates inefficient polling activity).
	//
	//	No other thread-safe,  synchronised or scheduling classes or methods may be used. In particular:
	//	•	The keyword synchronized, and other classes from the package java.util.concurrent must be not be used. 
	//	•	Thread.Sleep() and any other methods that affect thread scheduling must not be used.
	//	•	“Busy waiting” techniques, such as spinlocks, must not be used. 
	//	Other non-thread-safe classes from SE17 may be used, e.g. LinkedLists, HashMaps and ArrayLists 
 	//	(these are unsynchronised and therefore not thread-safe).

    //See the Coursework spec for full list of constraints marking penalties

    import java.util.*;
    import java.util.concurrent.locks.Condition;
    import java.util.concurrent.locks.ReentrantLock;
    
    public class JobManager implements Manager {
        @Override
        public void specifyJob(JobRequest job) {
            lock.lock();
            try {
                jobQueue.addLast(job);
                processJobs();
            } finally {
                lock.unlock();
            }
        }
    
        @Override
        public String serverLogin(String type, int ID) {
            lock.lock();
            try {
                waitingServers.putIfAbsent(type, new LinkedList<>());
                Condition condition = lock.newCondition();
                Server server = new Server(type, ID, condition);
                waitingServers.get(type).add(server);
                processJobs();
    
                while (!server.assigned) {
                    condition.await();
                }
                return server.assignedJobName;  

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return null;
            } finally {
                lock.unlock();
            }
        }
        
        //==================================== PRIVATE METHODS & CLASSES  ===============================================
        
        private final ReentrantLock lock = new ReentrantLock();
        private final LinkedList<JobRequest> jobQueue = new LinkedList<>();
        private final HashMap<String, LinkedList<Server>> waitingServers = new HashMap<>();
    
        private static class Server {
            String type;
            int ID;
            Condition condition;
            boolean assigned = false;
            String assignedJobName;  // Will store the job's string representation
    
            Server(String type, int ID, Condition condition) {
                this.type = type;
                this.ID = ID;
                this.condition = condition;
            }
        }
    
        private void processJobs() {
            Iterator<JobRequest> jobIterator = jobQueue.iterator();
            while (jobIterator.hasNext()) {
                JobRequest job = jobIterator.next();
                HashMap<String, Integer> neededServers = new HashMap<>(job);
                boolean canAssign = true;
    
                // Checks if all required servers are available
                for (Map.Entry<String, Integer> entry : neededServers.entrySet()) {
                    String serverType = entry.getKey();
                    int requiredCount = entry.getValue();
                    LinkedList<Server> availableServers = waitingServers.get(serverType);
    
                    if (availableServers == null || availableServers.size() < requiredCount) {
                        canAssign = false;
                    }
                }
    
                if (canAssign) {
                    // Assign servers to this job
                    String jobString = job.toString();  // Using toString() as we can't use getJobName()  
                    String jobName = jobString.substring(
                    jobString.indexOf("jobName=") + 8, 
                    jobString.indexOf(',', jobString.indexOf("jobName="))
                ).trim();

                    jobIterator.remove();
    
                    for (Map.Entry<String, Integer> entry : neededServers.entrySet()) {
                        String serverType = entry.getKey();
                        int requiredCount = entry.getValue();
                        LinkedList<Server> availableServers = waitingServers.get(serverType);
    
                        // Sort servers by ID in descending order
                        availableServers.sort((a, b) -> Integer.compare(b.ID, a.ID));
    
                        // Assign required number of servers
                        for (int i = 0; i < requiredCount; i++) {
                            Server assignedServer = availableServers.removeFirst();
                            assignedServer.assigned = true;
                            assignedServer.assignedJobName = jobName;
                            assignedServer.condition.signal();
                        }
                    }
                }
            }
        }
    }

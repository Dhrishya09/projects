# F29OC Concurrency Coursework - Job Manager Simulation

## Project Overview

This project implements a thread-safe Job Manager system that coordinates server resources to fulfill computational job requests. The system manages different types of servers (ComputeServers, StorageServers, etc.) and allocates them to jobs according to specified requirements while maintaining thread safety and efficient resource utilization.

## Key Features

- **Extrinsic Monitor Implementation**: Uses `ReentrantLock` and `Condition` variables for thread synchronization
- **Job Scheduling**: Processes job requests in FIFO order with proper resource allocation
- **Server Management**: Handles server logins and assigns them to appropriate jobs
- **Thread Safety**: Ensures consistent behavior under concurrent access without race conditions
- **Resource Allocation**: Implements reverse ID ordering for ComputeServer assignment (UR6)

## Technical Highlights

- Implemented using Java SE17 concurrency primitives
- No use of synchronized blocks or other thread-safe libraries
- Avoids busy waiting through proper use of condition variables
- Handles mixed server types and complex job requirements
- Maintains FIFO ordering of job requests

## Development Approach

- Incremental development with frequent commits (25+ meaningful commits)
- Comprehensive testing for all user requirements
- Focus on thread safety and consistent behavior
- Proper documentation and commit messages

## How to Run

1. Clone the repository
2. Compile with Java SE17
3. Run the Main class or individual tests from Tests.java

## Example Usage

```java
// Create job manager
Manager jobManager = new JobManager();

// Start servers (in separate threads)
new Thread(() -> {
    String jobName = jobManager.serverLogin("ComputeServer", 100);
    System.out.println("Assigned to job: " + jobName);
}).start();

// Specify job requirements
Map<String, Integer> jobSpec = new HashMap<>();
jobSpec.put("ComputeServer", 2);
jobSpec.put("StorageServer", 1);
JobRequest job = new JobRequest("job01", jobSpec);

jobManager.specifyJob(job);
```

## Skills Demonstrated

- Advanced Java concurrency programming
- Thread synchronization techniques
- Resource management algorithms
- Software testing methodologies
- Version control best practices
- Problem-solving in concurrent systems

This project serves as an excellent demonstration of my ability to design and implement complex concurrent systems while adhering to strict requirements and maintaining thread safety.





using System;
using System.Collections.Generic;
class Program
{
   static void Main()
   {
       // Create a priority queue
       var pq = new PriorityQueue<string, int>();
       // Add elements with priorities
       pq.Enqueue("Task 1", 3); // Lower number = higher priority
       pq.Enqueue("Task 2", 1);
       pq.Enqueue("Task 3", 2);
       Console.WriteLine("Dequeuing elements based on priority:");
       // Remove and display elements in priority order
       while (pq.TryDequeue(out string task, out int priority))
       {
           Console.WriteLine($"{task} with priority {priority}");
       }
   }
}

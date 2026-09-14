class PriorityQueue {
   constructor() {
       this.heap = [];
   }
   // Helper methods for heap operations
   getParentIndex(index) { return Math.floor((index - 1) / 2); }
   getLeftChildIndex(index) { return 2 * index + 1; }
   getRightChildIndex(index) { return 2 * index + 2; }
   swap(i, j) {
       [this.heap[i], this.heap[j]] = [this.heap[j], this.heap[i]];
   }
   // Add an element to the queue
   enqueue(element) {
       this.heap.push(element);
       this.heapifyUp();
   }
   // Remove the highest-priority element
   dequeue() {
       if (this.heap.length === 0) return null;
       const root = this.heap[0];
       this.heap[0] = this.heap.pop();
       this.heapifyDown();
       return root;
   }
   // Maintain heap property after insertion
   heapifyUp() {
       let index = this.heap.length - 1;
       while (index > 0 && this.heap[index] < this.heap[this.getParentIndex(index)]) {
           this.swap(index, this.getParentIndex(index));
           index = this.getParentIndex(index);
       }
   }
   // Maintain heap property after removal
   heapifyDown() {
       let index = 0;
       while (this.getLeftChildIndex(index) < this.heap.length) {
           let smallerChildIndex = this.getLeftChildIndex(index);
           if (this.getRightChildIndex(index) < this.heap.length &&
               this.heap[this.getRightChildIndex(index)] < this.heap[smallerChildIndex]) {
               smallerChildIndex = this.getRightChildIndex(index);
           }
           if (this.heap[index] <= this.heap[smallerChildIndex]) break;
           this.swap(index, smallerChildIndex);
           index = smallerChildIndex;
       }
   }
}
// Example usage
const pq = new PriorityQueue();
pq.enqueue(10);
pq.enqueue(5);
pq.enqueue(20);
console.log(pq.dequeue()); // Output: 5
console.log(pq.dequeue()); // Output: 10

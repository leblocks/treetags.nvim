local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

-- Create a new priority queue
function PriorityQueue:new()
    return setmetatable({ heap = {} }, self)
end

-- Swap two elements in the heap
local function swap(heap, i, j)
    heap[i], heap[j] = heap[j], heap[i]
end

-- Move element up to maintain heap property
local function heapify_up(heap, index)
    while index > 1 do
        local parent = math.floor(index / 2)
        if heap[index].priority < heap[parent].priority then
            swap(heap, index, parent)
            index = parent
        else
            break
        end
    end
end

-- Move element down to maintain heap property
local function heapify_down(heap, index)
    local size = #heap
    while true do
        local left = index * 2
        local right = left + 1
        local smallest = index

        if left <= size and heap[left].priority < heap[smallest].priority then
            smallest = left
        end
        if right <= size and heap[right].priority < heap[smallest].priority then
            smallest = right
        end
        if smallest ~= index then
            swap(heap, index, smallest)
            index = smallest
        else
            break
        end
    end
end

-- Insert a new element with a given priority
function PriorityQueue:push(value, priority)
    if type(priority) ~= 'number' then
        error('Priority must be a number', 2)
    end
    table.insert(self.heap, { value = value, priority = priority })
    heapify_up(self.heap, #self.heap)
end

-- Peek at the element with the highest priority (lowest priority number)
function PriorityQueue:peek()
    if #self.heap == 0 then
        return nil
    end
    return self.heap[1].value, self.heap[1].priority
end

-- Remove and return the element with the highest priority
function PriorityQueue:pop()
    if #self.heap == 0 then
        return nil
    end
    local root = self.heap[1]
    self.heap[1] = self.heap[#self.heap]
    table.remove(self.heap)
    if #self.heap > 0 then
        heapify_down(self.heap, 1)
    end
    return root.value, root.priority
end

-- Update the priority of an existing value (linear search)
function PriorityQueue:update(value, new_priority)
    for i, node in ipairs(self.heap) do
        if node.value == value then
            node.priority = new_priority
            heapify_up(self.heap, i)
            heapify_down(self.heap, i)
            return true
        end
    end
    return false -- Value not found
end

-- Check if queue is empty
function PriorityQueue:is_empty()
    return #self.heap == 0
end

-- Get size of the queue
function PriorityQueue:size()
    return #self.heap
end

-- Example usage
local pq = PriorityQueue:new()
pq:push('Task A', 3)
pq:push('Task B', 1)
pq:push('Task C', 2)

print('Peek:', pq:peek()) -- Task B, priority 1

while not pq:is_empty() do
    local value, priority = pq:pop()
    print('Popped:', value, 'Priority:', priority)
end

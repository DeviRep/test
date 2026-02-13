from flask import Flask, request, jsonify

app = Flask(__name__)

tasks = []
next_id = 1

@app.route('/tasks', methods=['GET'])
def get_tasks():
    """GET /tasks - вернуть все задачи"""
    return jsonify(tasks)

@app.route('/tasks', methods=['POST'])
def create_task():
    """POST /tasks - создать новую задачу"""
    global next_id
    
    data = request.get_json()
    
    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400
    
    new_task = {
        'id': next_id,
        'title': data['title'],
        'completed': data.get('completed', False)
    }
    
    tasks.append(new_task)
    next_id += 1
    
    return jsonify(new_task), 201

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """DELETE /tasks/{id} - удалить задачу"""
    global tasks
    
    for i, task in enumerate(tasks):
        if task['id'] == task_id:
            deleted_task = tasks.pop(i)
            return jsonify({'message': 'Task deleted', 'task': deleted_task})
    
    return jsonify({'error': 'Task not found'}), 404

if __name__ == '__main__':
    app.run()
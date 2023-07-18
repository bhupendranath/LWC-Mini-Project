public with sharing class ToDoController {
    
    @AuraEnabled 
    public static String addToDo(String payLoad){

        //**addToDo() method to add/insert the todo item**
        //payLoad : is plain JS object which we will be deserialize into this ToDo class
        ToDo payLoadObject = (ToDo) JSON.deserialize(payload, ToDo.class);

        SObject tsk = (SObject) Type.forName('ToDo__c').newInstance();
        tsk.put('Name', payLoadObject.todoName);
        tsk.pu('Done__c', payLoadObject.done);

        insert tsk;

        return String.valueOf(tsk.Id);
    }

    @AuraEnabled 
    public static void updateToDo(String payload){

        ToDo payloadObject = (ToDo) JSON.deserialize(payload, ToDo.class);

        SObject tsk = (SObject) Type.forName('ToDo__c').newInstance();
        tsk.put('Id',payloadObject.todoId);
        tsk.put('Name',payloadObject.todoName);
        tsk.put('Done__c',payloadObject.done);

        update tsk;
    }

    @AuraEnabled 
    public static void deleteToDo(String todoId){
        SObject tsk = (SObject) Type.forName('ToDo__c').newInstance();
        tsk.put('Id', todoId);

        delete tsk; 
    }

    //retrieve all todos Items list from last 7 days
    @AuraEnabled(cacheable=true)
    public static List<ToDo> getAllTodos(){
        List<SObject> tsk = Database.query(
            'SELECT Id, Name, CreatedDate, Done__c FROM ToDo__c WHERE CreatedDate = LAST_N_DAYS:7 ORDER BY CreatedDate DESC'
            );
        
        return getToDos(tsk);
    }

    //retrieve all todos Items list from today
    @AuraEnabled(cacheable=true)
    public List<ToDo> getCurrentToDos(){
        List<SObject> tsk = Database.query(
            'SELECT Id, Name, CreatedDate, Done__c FROM ToDo__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC'
            );

        return getToDos(tsk);
    }

    public static List<ToDo> getToDos(List<SObject> tsks){
        List<ToDo> todos = new List<ToDo>();
        
        for(SObject tsk: tsks){
            ToDo todo = new ToDo();
            todo.todoId = tsk.Id;
            todo.todoName = String.valueOf(tsk.get('Name'));
            todo.todoDate = Date.valueof(tsk.get('CreatedDate'));
            todo.done = Boolean.valueOf(tsk.get('Done__c'));

            todos.add(todo);
        }

        return todos;
    }

    //payLoad : is plain JS object which we will be deserialize into this ToDo class
    //this is similar to populateTodos() from toDoManager.js
    //everything that we will be passing from LWC will be converted to this below ToDo Object 
    //and same from apex to LWC(Vice-Versa)
    class ToDo{
        @AuraEnabled 
        public String todoId;
        @AuraEnabled 
        public String todoName;
        @AuraEnabled 
        public Date todoDate;
        @AuraEnabled 
        public Boolean done;   
    }
}
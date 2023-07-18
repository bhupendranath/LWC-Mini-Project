import { LightningElement, api } from 'lwc';

export default class ToDoItem extends LightningElement {

    @api todoId;
    @api todoName;
    @api done = false;

    //we are defining CSS class
    get containerClass(){
        return this.done ? "todo completed" : "todo upcoming";
    }
}

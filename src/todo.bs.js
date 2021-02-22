// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Fs = require("fs");
var Os = require("os");
var Curry = require("bs-platform/lib/js/curry.js");
var Belt_Int = require("bs-platform/lib/js/belt_Int.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Caml_array = require("bs-platform/lib/js/caml_array.js");

var getToday = (function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
});

var encoding = "utf8";

var helpStr = "Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics";

function readTodos(fileName) {
  if (!Fs.existsSync(fileName)) {
    return [];
  }
  var data = Fs.readFileSync(fileName, {
        encoding: encoding,
        flag: "r"
      });
  var todos = data.split("\n");
  return todos.filter(function (todo) {
              return todo.length > 0;
            });
}

function writeToFile(fileName, text, append) {
  if (Fs.existsSync(fileName) && append) {
    Fs.appendFileSync(fileName, text + Os.EOL, {
          encoding: encoding,
          flag: "a"
        });
  } else {
    Fs.writeFileSync(fileName, text + Os.EOL, {
          encoding: encoding,
          flag: "w"
        });
  }
  
}

function printAns(str) {
  console.log(str);
  
}

function listTodos(param) {
  var todos = readTodos("todo.txt");
  if (todos.length === 0) {
    console.log("There are no pending todos!");
  }
  var todos$1 = todos.map(function (todo, index) {
        return "[" + String(index + 1 | 0) + "] " + todo;
      });
  Belt_Array.reverseInPlace(todos$1);
  var todos$2 = Belt_Array.reduce(todos$1, "", (function (str, todo) {
          var todo$1 = todo.replace("\r", "");
          return str + todo$1 + "\n";
        }));
  console.log(todos$2);
  
}

function addTodo(todo) {
  if (todo !== undefined) {
    writeToFile("todo.txt", todo, true);
    console.log("Added todo: \"" + todo + "\"");
  } else {
    console.log("Error: Missing todo string. Nothing added!");
  }
  
}

function deleteTodo(todoNum) {
  if (todoNum !== undefined) {
    var todos = readTodos("todo.txt");
    var todoNum$1 = Belt_Int.fromString(todoNum);
    if (todoNum$1 !== undefined) {
      if (todoNum$1 > todos.length || todoNum$1 === 0) {
        console.log("Error: todo #" + String(todoNum$1) + " does not exist. Nothing deleted.");
        return ;
      }
      var todos$1 = todos.filter(function (item, idx) {
            return (todoNum$1 - 1 | 0) !== idx;
          });
      var todos$2 = Belt_Array.reduce(todos$1, "", (function (str, todo) {
              return str + todo + "\n";
            }));
      Fs.writeFileSync("todo.txt", todos$2, {
            encoding: encoding,
            flag: "w"
          });
      console.log("Deleted todo #" + String(todoNum$1));
      return ;
    }
    console.log("Error: todo #" + todoNum + " does not exist. Nothing deleted.");
    return ;
  }
  console.log("Error: Missing NUMBER for deleting todo.");
  
}

function todoCompleted(todoNum) {
  if (todoNum !== undefined) {
    var todos = readTodos("todo.txt");
    var todoNum$1 = Belt_Int.fromString(todoNum);
    if (todoNum$1 !== undefined) {
      if (todoNum$1 > todos.length || todoNum$1 === 0) {
        console.log("Error: todo #" + String(todoNum$1) + " does not exist.");
        return ;
      }
      var completedTodo = Caml_array.get(todos, todoNum$1 - 1 | 0);
      var todos$1 = todos.filter(function (item, idx) {
            return (todoNum$1 - 1 | 0) !== idx;
          });
      var todos$2 = Belt_Array.reduce(todos$1, "", (function (str, todo) {
              return str + todo + "\n";
            }));
      Fs.writeFileSync("todo.txt", todos$2, {
            encoding: encoding,
            flag: "w"
          });
      writeToFile("done.txt", completedTodo, true);
      console.log("Marked todo #" + String(todoNum$1) + " as done.");
      return ;
    }
    console.log("Error: todo #" + todoNum + " does not exist.");
    return ;
  }
  console.log("Error: Missing NUMBER for marking todo as done.");
  
}

function report(param) {
  var pendingTodos = readTodos("todo.txt");
  var completedTodos = readTodos("done.txt");
  console.log(Curry._1(getToday, undefined) + " Pending : " + String(pendingTodos.length) + " Completed : " + String(completedTodos.length));
  
}

var match = Belt_Array.get(process.argv, 2);

if (match !== undefined) {
  switch (match) {
    case "add" :
        addTodo(Belt_Array.get(process.argv, 3));
        break;
    case "del" :
        deleteTodo(Belt_Array.get(process.argv, 3));
        break;
    case "done" :
        todoCompleted(Belt_Array.get(process.argv, 3));
        break;
    case "ls" :
        listTodos(undefined);
        break;
    case "report" :
        report(undefined);
        break;
    default:
      console.log(helpStr);
  }
} else {
  console.log(helpStr);
}

exports.getToday = getToday;
exports.encoding = encoding;
exports.helpStr = helpStr;
exports.readTodos = readTodos;
exports.writeToFile = writeToFile;
exports.printAns = printAns;
exports.listTodos = listTodos;
exports.addTodo = addTodo;
exports.deleteTodo = deleteTodo;
exports.todoCompleted = todoCompleted;
exports.report = report;
/* match Not a pure module */

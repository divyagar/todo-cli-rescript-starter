/*
Sample JS implementation of Todo CLI that you can attempt to port:
https://gist.github.com/jasim/99c7b54431c64c0502cfe6f677512a87
*/

/* Returns date with the format: 2021-02-04 */
let getToday: unit => string = %raw(`
function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
}
  `)

type fsConfig = {encoding: string, flag: string}

/* https://nodejs.org/api/fs.html#fs_fs_existssync_path */
@bs.module("fs") external existsSync: string => bool = "existsSync"

/* https://nodejs.org/api/fs.html#fs_fs_readfilesync_path_options */
@bs.module("fs")
external readFileSync: (string, fsConfig) => string = "readFileSync"

/* https://nodejs.org/api/fs.html#fs_fs_writefilesync_file_data_options */
@bs.module("fs")
external appendFileSync: (string, string, fsConfig) => unit = "appendFileSync"

@bs.module("fs")
external writeFileSync: (string, string, fsConfig) => unit = "writeFileSync"

/* https://nodejs.org/api/os.html#os_os_eol */
@bs.module("os") external eol: string = "EOL"

@bs.val @scope("process") external argv: array<string> = "argv"

let encoding = "utf8"

/*
NOTE: The code below is provided just to show you how to use the
date and file functions defined above. Remove it to begin your implementation.
*/

// help text
let helpStr = `Usage :-
$ ./todo add "todo item"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics`

// helper function to read todos from both files and return todos after filtering them
let readTodos = fileName => {
  if existsSync(fileName) {
    let data = readFileSync(fileName, {encoding: encoding, flag: "r"})
    let todos = Js.String.split("\n", data)
    let todos = Js.Array.filter(todo => Js.String2.length(todo) > 0, todos)
    todos
  } else {
    let emptyArr = []
    emptyArr
  }
}

// helper function to write or append to a file
let writeToFile = (fileName, text, append) => {
  if existsSync(fileName) && append {
    appendFileSync(fileName, text ++ eol, {encoding: encoding, flag: "a"})
  } else {
    writeFileSync(fileName, text ++ eol, {encoding: encoding, flag: "w"})
  }
}

let printAns = str => Js.log(str)

let listTodos = () => {
  let todos = readTodos("todo.txt")
  if todos->Belt.Array.length == 0 {
    Js.log("There are no pending todos!")
  }
  let todos = Js.Array.mapi((todo, index) => `[${Belt.Int.toString(index + 1)}] ${todo}`, todos)

  // reversing todos array
  Belt.Array.reverseInPlace(todos)

  // reducing all todos to a single string
  let todos = Belt.Array.reduce(todos, "", (str, todo) => {
    let todo = Js.String.replace("\r", "", todo)
    str ++ todo ++ "\n"
  })

  Js.log(todos)
}

let addTodo = todo => {
  switch todo {
  | None => Js.log("Error: Missing todo string. Nothing added!")
  | Some(todo) => {
      // appending todo to todo.txt
      writeToFile("todo.txt", todo, true)
      Js.log(`Added todo: "${todo}"`)
    }
  }
}

let deleteTodo = todoNum => {
  switch todoNum {
  | None => Js.log("Error: Missing NUMBER for deleting todo.")
  | Some(todoNum) => {
      let todos = readTodos("todo.txt")

      switch Belt.Int.fromString(todoNum) {
      | None => Js.log(`Error: todo #${todoNum} does not exist. Nothing deleted.`)
      | Some(todoNum) =>
        // if todo with given index does not exist
        if todoNum > todos->Belt.Array.length || todoNum == 0 {
          Js.log(`Error: todo #${Belt.Int.toString(todoNum)} does not exist. Nothing deleted.`)
        } else {
          // removing todo from todos array which is to be deleted
          let todos = Js.Array.filteri((item, idx) => todoNum - 1 != idx, todos)

          // reducing all todos array to a single string
          let todos = Belt.Array.reduce(todos, "", (str, todo) => str ++ todo ++ "\n")

          // writing all remaining todos to todo.txt
          writeFileSync("todo.txt", todos, {encoding: encoding, flag: "w"})
          Js.log(`Deleted todo #${Belt.Int.toString(todoNum)}`)
        }
      }
    }
  }
}

let todoCompleted = todoNum => {
  switch todoNum {
  | None => Js.log("Error: Missing NUMBER for marking todo as done.")
  | Some(todoNum) => {
      let todos = readTodos("todo.txt")

      switch Belt.Int.fromString(todoNum) {
      | None => Js.log(`Error: todo #${todoNum} does not exist.`)
      | Some(todoNum) =>
        // if todo with given index does not exist
        if todoNum > todos->Belt.Array.length || todoNum == 0 {
          Js.log(`Error: todo #${Belt.Int.toString(todoNum)} does not exist.`)
        } else {
          let completedTodo = todos[todoNum - 1]

          // removing completed todo from todos array
          let todos = Js.Array.filteri((item, idx) => todoNum - 1 != idx, todos)

          // reducing all todos to a single string
          let todos = Belt.Array.reduce(todos, "", (str, todo) => str ++ todo ++ "\n")

          // writing all remaining todos back to todo.txt file
          writeFileSync("todo.txt", todos, {encoding: encoding, flag: "w"})

          // appending completed todo to done.txt file
          writeToFile("done.txt", completedTodo, true)
          Js.log(`Marked todo #${Belt.Int.toString(todoNum)} as done.`)
        }
      }
    }
  }
}

let report = () => {
  let pendingTodos = readTodos("todo.txt")
  let completedTodos = readTodos("done.txt")
  Js.log(
    `${getToday()} Pending : ${Belt.Int.toString(
        Belt.Array.length(pendingTodos),
      )} Completed : ${Belt.Int.toString(Belt.Array.length(completedTodos))}`,
  )
}

switch argv->Belt.Array.get(2) {
| Some("ls") => listTodos()
| Some("add") => addTodo(argv->Belt.Array.get(3))
| Some("del") => deleteTodo(argv->Belt.Array.get(3))
| Some("done") => todoCompleted(argv->Belt.Array.get(3))
| Some("report") => report()
| _ => Js.log(helpStr)
}

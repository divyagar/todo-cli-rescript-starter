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

let encoding = "utf8"

/*
NOTE: The code below is provided just to show you how to use the
date and file functions defined above. Remove it to begin your implementation.
*/

// function to get arguments
let getArgs = %raw(`function(){
    return process.argv
}`)

let args = getArgs()

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

// if there is no argument or first argument is help print help text
if Js.Array.length(args) == 2 || args[2] == "help" {
  Js.log(helpStr)
} else if args[2] == "ls" {
  let todos = readTodos("todo.txt")

  // if there is no todos
  if Js.Array.length(todos) == 0 {
    Js.log("There are no pending todos!")
  } else {
    // mapping each todo and its respective index together
    let todos = Js.Array2.mapi(todos, (todo, index) => `[${Belt.Int.toString(index + 1)}] ${todo}`)

    // reversing todos array
    let todos = Js.Array2.reverseInPlace(todos)

    // reducing all todos to a single string
    let todos = Js.Array2.reduce(
      todos,
      (str, todo) => {
        let todo = Js.String.replace("\r", "", todo)
        str ++ todo ++ "\n"
      },
      "",
    )

    Js.log(todos)
  }
} else if args[2] == "add" {
  // if there is no second argument
  if Js.Array.length(args) == 3 {
    Js.log("Error: Missing todo string. Nothing added!")
  } else {
    // appending todo to todo.txt
    writeToFile("todo.txt", args[3], true)
    Js.log(`Added todo: "${args[3]}"`)
  }
} else if args[2] == "del" {
  // if index of todo to be deleted is not given
  if Js.Array.length(args) == 3 {
    Js.log("Error: Missing NUMBER for deleting todo.")
  } else {
    let todos = readTodos("todo.txt")
    let index = args[3]

    // if todo with given index does not exist
    if index > Js.Array.length(todos) || index == "0" {
      Js.log(`Error: todo #${index} does not exist. Nothing deleted.`)
    } else {
      // removing todo from todos array which is to be deleted
      let todos = Js.Array2.filteri(todos, (item, idx) => index - 1 != idx)

      // reducing all todos array to a single string
      let todos = Js.Array2.reduce(todos, (str, todo) => str ++ todo ++ "\n", "")

      // writing all remaining todos to todo.txt
      writeFileSync("todo.txt", todos, {encoding: encoding, flag: "w"})
      Js.log(`Deleted todo #${index}`)
    }
  }
} else if args[2] == "done" {
  // if second argument is not given
  if Js.Array.length(args) == 3 {
    Js.log("Error: Missing NUMBER for marking todo as done.")
  } else {
    let todos = readTodos("todo.txt")
    let index = args[3]

    // if todo with given index does not exist
    if index > Js.Array.length(todos) || index == "0" {
      Js.log(`Error: todo #${index} does not exist.`)
    } else {
      let completedTodo = todos[index - 1]

      // removing completed todo from todos array
      let todos = Js.Array2.filteri(todos, (item, idx) => index - 1 != idx)

      // reducing all todos to a single string
      let todos = Js.Array2.reduce(todos, (str, todo) => str ++ todo ++ "\n", "")

      // writing all remaining todos back to todo.txt file
      writeFileSync("todo.txt", todos, {encoding: encoding, flag: "w"})

      // appending completed todo to done.txt file
      writeToFile("done.txt", completedTodo, true)
      Js.log(`Marked todo #${index} as done.`)
    }
  }
} else if args[2] == "report" {
  let pendingTodos = readTodos("todo.txt")
  let completedTodos = readTodos("done.txt")
  Js.log(
    `${getToday()} Pending : ${Belt.Int.toString(
        Js.Array.length(pendingTodos),
      )} Completed : ${Belt.Int.toString(Js.Array.length(completedTodos))}`,
  )
}

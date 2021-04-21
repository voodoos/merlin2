Works for in-file modules
  $ $MERLIN single refactor-open -action qualify -position 4:6 <<EOF
  > module M = struct
  >   let u = ()
  > end
  > open M
  > let u = u
  > EOF
  {
    "class": "return",
    "value": [
      {
        "start": {
          "line": 5,
          "col": 8
        },
        "end": {
          "line": 5,
          "col": 9
        },
        "content": "M.u"
      }
    ],
    "notifications": []
  }

Works for in-file nested modules

  $ $MERLIN single refactor-open -action qualify -position 6:6 <<EOF
  > module M = struct
  >   module N = struct
  >     let u = ()
  >   end
  > end
  > open M.N
  > let u = u
  > EOF
  {
    "class": "return",
    "value": [
      {
        "start": {
          "line": 7,
          "col": 8
        },
        "end": {
          "line": 7,
          "col": 9
        },
        "content": "M.N.u"
      }
    ],
    "notifications": []
  }

Works for stdlib modules (stdlib modules differ from other in-file modules because their
full path is different)

  $ $MERLIN single refactor-open -action qualify -position 1:6 <<EOF
  > open Unix
  > let times = times ()
  > EOF
  {
    "class": "return",
    "value": [
      {
        "start": {
          "line": 2,
          "col": 12
        },
        "end": {
          "line": 2,
          "col": 17
        },
        "content": "Unix.times"
      }
    ],
    "notifications": []
  }

refactor open qualify use short paths - 2

  $ $MERLIN single refactor-open -action qualify -position 8:6 <<EOF
  > module L = struct
  >   module M = struct
  >     module N = struct
  >       let u = ()
  >     end
  >   end
  > end
  > open L 
  > open M.N
  > let () = u
  > EOF
  {
    "class": "return",
    "value": [
      {
        "start": {
          "line": 9,
          "col": 5
        },
        "end": {
          "line": 9,
          "col": 8
        },
        "content": "L.M.N"
      },
      {
        "start": {
          "line": 10,
          "col": 9
        },
        "end": {
          "line": 10,
          "col": 10
        },
        "content": "L.M.N.u"
      }
    ],
    "notifications": []
  }


open Bos
open Rresult
open R.Infix

let opam = Cmd.(v "opam" % "exec" % "--")

let opam_tools = Sys.getcwd () ^ "/" ^ Sys.argv.(1)

let run dir =
  OS.Dir.with_current dir
    (fun () ->
      OS.Cmd.run Cmd.(opam % opam_tools % "-vv")
      >>= (fun () ->
            OS.Cmd.run Cmd.(opam % "dune" % "build" % "@install" % "@doc")
            >>= fun () -> OS.Cmd.run Cmd.(v "ls" % "-la" % "_opam/bin"))
      |> R.get_ok)
    ()
  |> R.get_ok

let () =
  List.iter
    (fun proj ->
      OS.Dir.with_tmp
        (format_of_string "opamtools%s")
        (fun dir () ->
          Printf.printf "\nCloning %s to %s\n%!" proj (Fpath.to_string dir);
          OS.Cmd.run
            Cmd.(v "opam" % "source" % proj % "--dir" % p Fpath.(dir / proj))
          |> R.get_ok;
          Printf.printf "Testing: %s\n%!" proj;
          run Fpath.(dir / proj))
        ()
      |> R.get_ok)
    [ "patdiff"; "mirage"; "qcow"; "h2" ]

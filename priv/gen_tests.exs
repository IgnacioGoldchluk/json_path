tests = Path.join(["test", "cts.json"]) |> File.read!() |> JSON.decode!() |> Map.fetch!("tests")
template = EEx.eval_file(Path.join(["priv", "templates", "compliance_test.exs.eex"]), tests: tests)
File.write!(Path.join(["test", "json_path", "compliance_test.exs"]), template)

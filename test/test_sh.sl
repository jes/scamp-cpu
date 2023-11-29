var test_sh = func() {
    system(["/bin/sh", "-c", "ls", "-1", "test*.sl", "| sort > ls.out"]);
    system(["/bin/sh", "-c", "cat ls.*"]);
    system(["/bin/sh", "-c", "echo foo 'single quotes' \"double quotes\""]);
};

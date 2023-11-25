var test_sh = func() {
    system(["/bin/sh", "-c", "ls", "-1", "test*.sl", "| sort > ls.out"]);
    system(["/bin/sh", "-c", "cat ls.*"]);
};

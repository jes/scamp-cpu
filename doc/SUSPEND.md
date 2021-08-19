# Suspend to disk

We could suspend a running session by dumping the contents of memory to a file on disk and then
restoring it at next boot. We could add a special key shortcut for this (along the lines of Ctrl-C
to exit a program and Ctrl-L to clear the screen), but since we already have Ctrl-Z to spawn a subshell,
it might be better to have a `suspend` command.

Rather than automatically restoring the previous session at the next boot, we could have the boot process
completely unaware of suspended sessions, and a `resume` command to resume the suspended one. The only
change required here is that we need to move the contents of `/proc/` to `/proc/suspend/` or something
so that they aren't trampled by the new session's processes.

And by the time we have accepted that we need to copy the contents of `/proc/` somewhere else for
safe-keeping, there's no reason to limit ourselves to only 1 suspended session: we could make `suspend`
and `resume` take an argument specifying the session name (kind of like GNU screen session names), and then
we could have multiple separate sessions available.

If we have multiple sessions available, then there's no reason we can't switch between them, automatically
saving the current session and resuming the new one. This could even be the standard mode of operating
the computer.

Of course, a session doesn't currently store a huge amount of useful state. In fact the only thing I
can think of that you might want to resume is your place in a file in the `kilo` editor, or
a half-completed game of `hamurabi`. Perhaps if there's a long-running process it might be useful to
suspend it and then go about doing something else before resuming it, but the Ctrl-Z workflow can handle
most of what you'd want from that, as long as you're pretty sure you won't crash the system and have to
reset it. If the state of the long-running process is very important it might be worth saving before
you go off doing something risky.

Perhaps rather than `suspend` and `resume`, the nomenclature could be `save` and `load`? The difference
being that after a `suspend` you are done for the day, but after `save` you have just saved a checkpoint
and intend to carry on.

Perhaps `save("name")` could just be a system call and our hypothetically important long-running process
could call it of its own accord at sensible intervals so that it can be resumed even if the power goes off
or similar.

## Implementation

I think upon a `save()` we'd want to flush all write buffers and then dump the entire memory contents to
disk, along with the return address of the `save()` call and the stack pointer (roughly like we currently
do with `system()` - in fact perhaps that part could be factored out and used for both). Upon `load()`
we'd restore all of the memory contents - including the kernel. This might prove complicated because it
would overwrite the stack and pseudoregisters of the `load()` function that is trying to do the
restoring, so perhaps we'd cordon off a section of memory for `load()`'s stack, and not restore
anything over the top of it, and also not restore all (any?) of the pseudoregisters - we currently risk
trashing pseudoregisters on every system call anyway, so I don't think that should be a problem.

I think that should do the job. If that is enough to implement `save()` and `load()` then the rest of it
is just userspace programs to provide a sensible interface.

Probably `save` and `load` are bad names because they collide with too many other things. Maybe
`savesession` and `loadsession` or something?

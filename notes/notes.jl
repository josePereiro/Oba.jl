# This project aim to create a glue package for automatizing the note-taking process in Obsidian.
# At first, it will be an ill-mixture of specific and general tools, but I am pursuing the goal to support the note taking with a turing-complete programming language.
# Why Obsidian? Well, they have already implemented several major goals.
# I)   Represent the data in both a human and machine friendly format (a flavour of markdown)
# II)  Creates the syntax and semantics of key core features (tag, link, label, etc...)
# III) Implementation of a GUI for reading/editing the data
# IV)  A plugin system for extensions
# IV)  Have a lot of users
# 
# The main feature I believe is missing is the implementation of a full-featured scripting language in the notes.
# Like the template system but with heavy drugs.
# I want to have the whole power of julia (although nothing prevent other languages e.g. python) for modifying and analyzing a vault or set of vaults.

# TODO: create a Gmail API infrestructure (check SMTPClient.jl)
# The idea is to set automatically calendar events and so on...

# TODO: Start ObaObjects package
# Maybe an ObaScript is the first instance of an ObaObjects, 
# left the ASTs package only for the Core (Obsidian compatible) parsing
# The idea is that you can build several Objects of a same document(s)/portion.
# Different point of view (application oriented) of the same data. 
# Build the basic infrestruction to start an echosystem.

# TODO: add ![[output.md]] kind of stuff for repl functionality

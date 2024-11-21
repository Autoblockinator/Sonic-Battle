# Naming
All files and folders must use `snake_case` unless they are one of the following exceptions:
- A select few repo related files like README.md, LICENSE, etc.
- C# files which require `PascalCase`.

# Folder Structure
The guidelines are:
- Files and folders should be in folders with other directly related files and folders.
- Folders should contain the least children possible.
- If a file is referenced in scenes not in it's current folder and not in any descendant folders, then it should exist in the lowest possible folder where this is true.

Guideline example: There are characters in the game, hence the folder `characters`. Sonic is a character so him and all his files go in the `characters` folder. Except that not all files related to the Character class are directly related to sonic, so instead, him and all his directly related files, get their own folder inside the `characters` folder.

Keep in mind: These are only guidelines, not hard rules.

Obvious exceptions to these guidelines include:
- Assets: All assets go in the flat `assets` folder.
- C/C++ Files: These go in the `src` folder.

# Code
Every line of every code file must be 80 characters long or less to fit comfortably in the godot text editor window.

# Scenes
Every resource in a scene must store it's data in a separate file.

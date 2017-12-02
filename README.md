# minetest-edutest-ui
This mod provides user interface extensions for the MinetestEDU/EDUtest project. It depends on [my fork](https://github.com/apienk/edutest-chatcommands) of `edutest-chatcommands` mod by Isidor Zeuner.

**Contents:**
  1. [Mission statement](https://github.com/apienk/minetest-edutest-ui#mission-statement)
  1. [Dependencies](https://github.com/apienk/minetest-edutest-ui#dependencies)
  1. [GUI features](https://github.com/apienk/minetest-edutest-ui#gui-features)
      - [Components](https://github.com/apienk/minetest-edutest-ui#components)
      - [Inventory functions](https://github.com/apienk/minetest-edutest-ui#inventory-functions)
      - [Messaging functions](https://github.com/apienk/minetest-edutest-ui#messaging-functions)
      - [World functions](https://github.com/apienk/minetest-edutest-ui#world-functions)
      - [Other functions](https://github.com/apienk/minetest-edutest-ui#other-functions)
  1. [Installation](https://github.com/apienk/minetest-edutest-ui#installation)
  1. [To Do](https://github.com/apienk/minetest-edutest-ui#to-do)
  1. [Other useful mods to use in classroom](https://github.com/apienk/minetest-edutest-ui#other-useful-mods-to-use-in-classroom)
  1. [Some lesson ideas](https://github.com/apienk/minetest-edutest-ui#some-lesson-ideas)
      - [Mathematics](https://github.com/apienk/minetest-edutest-ui#mathematics)
      - [Science](https://github.com/apienk/minetest-edutest-ui#science)
      - [Languages](https://github.com/apienk/minetest-edutest-ui#languages)
  1. [Screenshots](https://github.com/apienk/minetest-edutest-ui#screenshots)

-------------------

## Mission statement

The goal of the MinetestEDU or EDUtest project is to make Minetest easy to use by a teacher in a classroom environment. The original idea was described in [this Minetest forum thread](https://forum.minetest.net/viewtopic.php?f=5&t=11452). The project is a collection of mods (a modpack) that allows teachers to feel in control of the students while in game.

**Note 1:** Buttons will only show up if optionally `their respective mods` are loaded

**Note 2:** The formspec tabs will only show up if player has `instructor` privilege

## Dependencies
- `edutest-chatcommands` https://github.com/apienk/edutest-chatcommands
- `areas` https://github.com/ShadowNinja/areas (optional)
- `teaching` https://github.com/apienk/minetest-teaching (optional)
- `invisible` https://forum.minetest.net/viewtopic.php?t=14399 (optional)
- `invmanagement` https://github.com/Sirvoid/InvManagement (optional)
- `jailbox` https://github.com/apienk/minetest-jailbox (optional)
- `freeze` https://github.com/PenguinDad/freeze (optional)

## GUI features

### Components
- student selector
- item selector with filtering
- itempack selector
- privilege selector
- area selector `areas`
- time selector

### Inventory functions
- \[_Give_\] give items to all students, a student or yourself
- \[_Give itempack_\] give itempacks (collections of items) to all students, a student or yourself
- \[_Store itempack_\] define a new itempack from your current inventory
- \[_Del_\] delete a stored itempack
- \[_Clear inv_\] clear inventory of all students, a student or yourself `invmanagement`
- \[_Check inv_\] check inventory of a student
- \[_Destroy item_\] destroy the item you wield

### Messaging functions
- \[_Message_\] message all students or a student using on-screen chat (top of screen, unintrusive)
- \[_Announce_\] message all students or a student using a custom dialog (center of screen, stops interaction)
- \[_Alphabetize_\] give oneself a complete set of letter/number blocks needed to build a message in the world `teaching`

### World functions
- \[_Create area_\] create a protected area (where only the owner can build or dig) for a student or yourself `areas`
- \[_Remove area_\] remove a protected area (where only the owner can build or dig) from a student or yourself `areas`
- \[_Open area_\] open an existing protected area for building and digging by non-owners `areas`
- \[_Close area_\] close an existing protected area for building and digging by non-owners `areas`
- \[_Create jailbox_\] erect an impenetrable and indestructible barrier box (jailbox) around an area to keep students from wandering too far or to protect it `jailbox`
- \[_Remove jailbox_\] remove the existing impenetrable and indestructible barrier box (jailbox) around an area `jailbox`
- \[_Bring me to_\] teleport yourself to a student
- \[_Bring to me_\] teleport all students or a student to yourself
- \[_Time_\] set in-game time (dawn, noon, dusk, midnight)

### Other functions
- \[_Heal_\] heal all students, a student or yourself
- \[_Freeze_\] freeze all students or a student (also mutes him or her in chat) `freeze`
- \[_Unfreeze_\] unfreeze all students or a student (also mutes him or her in chat) `freeze`
- \[_Grant priv_\] grant privileges to all students, a student or yourself (Note: if you need an assistant teacher grant him/her 'all' privileges)
- \[_Revoke priv_\] revoke privileges from all students, a student or yourself (Note: if you need an assistant teacher grant him/her 'all' privileges)
- \[_Invisible_\] turn yourself invisible `invisible`

## Installation
- download the repository as ZIP: https://github.com/apienk/minetest-edutest-ui/archive/master.zip
- unpack ZIP to your mods folder: `.minetest/mods/` on Linux or `minetest-install-directory/mods/` on Windows
- rename folder `minetest-edutest-ui-master` to `edutest-ui`
- enable the mod in your `world.mt` (add line `load_mod_edutest_ui=true`) or using the game GUI
- don't forget to install my fork of `edutest-chatcommands` mod (link below) as `edutest-ui` depends on it
- for complete functionality also install mods: `areas`, `jailbox`, `teaching` (preferably my fork, link below), `freeze`, `invmanagement`, `bookmarks_gui` (preferably my fork, link below), `invisible`
- to play as teacher grant yourself all privileges (type `/grantme all` in game)
- students don't need to be assigned any privileges to be affected by `all students` commands, just leave default (`shout` and `interact`)

## To do
- [ ] ask questions in formspec and aggregate answers
- [ ] student groups
- [ ] written assignments
- [ ] internationalization
- [ ] reward system
- [ ] controlled PvP

## Other useful mods to use in classroom
- my fork of `wardrobe` mod: https://github.com/apienk/minetest-mod-wardrobe (with nice GUI)

## Some lesson ideas

### Mathematics:
- build a city of buildings and ask students to calculate total blocks per building
- make students build a multiplication table (pyramid) from blocks
- give resources and make students estimate or calculate the number of goods that can be crafted from them (division with remainder)
- set up math problems from `teaching` blocks and make students compete by trying to find and solve; reward them with diamonds or alike
- calculate height of buildings using Tales equation

### Science:
- build a representation of the Solar System using real size and distance proportions (`worldedit` mod might be handy)
- experiment with conservation of energy by building a rollercoaster (requires `carts` mod)
- model an atom
- put students in an environment with very limited resources and discuss decisions that would lead to long-term survival
- renewable vs. non-renewable energy sources (requires `mesecons` or `technic` mod)

### Languages:
- set up a contest where students or student groups compete by building words from letter blocks
- recreate and play a situation from a piece of literature or movie

## Screenshots

![Edu tab](screenshot1.png)
![World tab](screenshot2.png)

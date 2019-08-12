import spryvm

import ui

type
  WidgetNode = ref object of Value
    widget*: Widget
  WindowNode* = ref object of WidgetNode
    onClosing*: Blok
  LabelNode = ref object of WidgetNode
  EntryNode = ref object of WidgetNode
    onChanged*: Blok
  MultilineEntryNode = ref object of WidgetNode
    onChanged*: Blok
  ComboBoxNode = ref object of WidgetNode
    onSelected*: Blok
  BoxNode = ref object of WidgetNode
  GroupNode = ref object of WidgetNode
  ButtonNode = ref object of WidgetNode
    onClicked*: Blok
  MenuNode = ref object of WidgetNode
    onClicked*: Blok
    onShouldQuit*: Blok
  MenuItemNode = ref object of WidgetNode
    onClicked*: Blok

method type*(self: WidgetNode): string {.base.} =
  "WidgetNode"
method `$`*(self: WindowNode): string =
  "WindowNode"
method `$`*(self: LabelNode): string =
  "LabelNode"
method `$`*(self: EntryNode): string =
  "EntryNode"
method `$`*(self: MultilineEntryNode): string =
  "MultilineEntryNode"
method `$`*(self: ComboBoxNode): string =
  "ComboBoxNode"
method `$`*(self: BoxNode): string =
  "BoxNode"
method `$`*(self: GroupNode): string =
  "GroupNode"
method `$`*(self: ButtonNode): string =
  "ButtonNode"
method `$`*(self: MenuNode): string =
  "MenuNode"
method `$`*(self: MenuItemNode): string =
  "MenuItemNode"

# Polymorphic setChild (because generics can't be used)
method setChild*(self: WidgetNode, child: WidgetNode) {.base.} =
  return
method setChild*(self: WindowNode, child: EntryNode) =
  Window(self.widget).setChild(Entry(child.widget))
method setChild*(self: WindowNode, child: MultilineEntryNode) =
  Window(self.widget).setChild(MultilineEntry(child.widget))
method setChild*(self: WindowNode, child: BoxNode) =
  Window(self.widget).setChild(Box(child.widget))
method setChild*(self: WindowNode, child: GroupNode) =
  Window(self.widget).setChild(Group(child.widget))
method setChild*(self: WindowNode, child: ButtonNode) =
  Window(self.widget).setChild(Button(child.widget))

method setChild*(self: GroupNode, child: EntryNode) =
  Group(self.widget).child = Entry(child.widget)
method setChild*(self: GroupNode, child: MultilineEntryNode) =
  Group(self.widget).child = MultilineEntry(child.widget)
method setChild*(self: GroupNode, child: BoxNode) =
  Group(self.widget).child =Box(child.widget)
method setChild*(self: GroupNode, child: GroupNode) =
  Group(self.widget).child = Group(child.widget)
method setChild*(self: GroupNode, child: ButtonNode) =
  Group(self.widget).child = Button(child.widget)

# Polymorphic text
method text(self: WidgetNode, text: string) {.base.} =
  return
method text(self: WidgetNode): string {.base.} =
  return
method text(self: LabelNode, text: string) =
  Label(self.widget).text = text
method text(self: LabelNode): string =
  Label(self.widget).text
method text(self: EntryNode, text: string) =
  Entry(self.widget).text = text
method text(self: EntryNode): string =
  Entry(self.widget).text
method text(self: MultilineEntryNode, text: string) =
  MultilineEntry(self.widget).text = text
method text(self: MultilineEntryNode): string =
  MultilineEntry(self.widget).text
method text(self: ButtonNode, text: string) =
  Button(self.widget).text = text
method text(self: ButtonNode): string =
  Button(self.widget).text

# Polymorphic title
method title(self: WidgetNode, title: string) {.base.} =
  return
method title(self: WidgetNode): string {.base.} =
  return
method title(self: WindowNode, title: string) =
  Window(self.widget).title = title
method title(self: WindowNode): string =
  Window(self.widget).title
method title(self: GroupNode, title: string) =
  Group(self.widget).title = title
method title(self: GroupNode): string =
  Group(self.widget).title

# Polymorphic readonly
method readonly(self: WidgetNode, readonly: bool) {.base.} =
  return
method readonly(self: WidgetNode): bool {.base.} =
  return
method readonly(self: EntryNode, readonly: bool) =
  Entry(self.widget).readonly = readonly
method readonly(self: EntryNode): bool =
  Entry(self.widget).readonly
method readonly(self: MultilineEntryNode, readonly: bool) =
  MultilineEntry(self.widget).readonly = readonly
method readonly(self: MultilineEntryNode): bool =
  MultilineEntry(self.widget).readonly

# These nodes only return themselves
method eval*(self: WidgetNode, spry: Interpreter): Node =
  self

# Spry UI module
proc addUI*(spry: Interpreter) =
  # libui startup, main loop and quit.
  nimFunc("uiInit"):
    ui.init()
  nimFunc("uiMain"):
    ui.mainLoop()
  nimFunc("uiQuit"):
    ui.quit()

  # File dialogs
  nimMeth("openFile"):
    var win = WindowNode(evalArgInfix(spry))
    var path = openFile(Window(win.widget))
    if path.isNil:
      spry.nilVal
    else:
      newValue($path)
  nimMeth("saveFile"):
    var win = WindowNode(evalArgInfix(spry))
    var path = saveFile(Window(win.widget))
    if path.isNil:
      spry.nilVal
    else:
      newValue($path)

  # Menu
  nimFunc("newMenu"):
    let name = StringVal(evalArg(spry)).value
    MenuNode(widget: newMenu(name))
  nimMeth("addItem:onClicked:"):
    let node = MenuNode(evalArgInfix(spry))
    let name = StringVal(evalArg(spry)).value
    let blok = Blok(evalArg(spry))
    let item = Menu(node.widget).addItem(name, proc() = discard blok.evalDo(spry))
    MenuItemNode(widget: item, onClicked: blok)
  nimMeth("addCheckItem:onClicked:"):
    let node = MenuNode(evalArgInfix(spry))
    let name = StringVal(evalArg(spry)).value
    let blok = Blok(evalArg(spry))
    let item = Menu(node.widget).addCheckItem(name, proc() = discard blok.evalDo(spry))
    MenuItemNode(widget: item, onClicked: blok)
  nimMeth("addQuitItemShouldClose:"):
    let node = MenuNode(evalArgInfix(spry))
    let blok = Blok(evalArg(spry))
    let item = Menu(node.widget).addQuitItem(proc(): bool {.closure.} =
      var shouldClose = blok.evalDo(spry)
      return BoolVal(shouldClose).value)
    MenuItemNode(widget: item, onClicked: blok)
  nimMeth("addPreferencesItemOnClicked:"):
    let node = MenuNode(evalArgInfix(spry))
    let blok = Blok(evalArg(spry))
    let item = Menu(node.widget).addPreferencesItem(proc() = discard blok.evalDo(spry))
    MenuItemNode(widget: item, onClicked: blok)
  nimMeth("addAboutItemOnClicked:"):
    let node = MenuNode(evalArgInfix(spry))
    let blok = Blok(evalArg(spry))
    let item = Menu(node.widget).addAboutItem(proc() = discard blok.evalDo(spry))
    MenuItemNode(widget: item, onClicked: blok)
  nimMeth("addSeparator"):
    let node = MenuNode(evalArgInfix(spry))
    Menu(node.widget).addSeparator()
    return node
  nimMeth("enable"):
    let node = MenuItemNode(evalArgInfix(spry))
    MenuItem(node.widget).enable
    return node
  nimMeth("disable"):
    let node = MenuItemNode(evalArgInfix(spry))
    MenuItem(node.widget).disable
    return node
  nimMeth("checked"):
    let node = MenuItemNode(evalArgInfix(spry))
    newValue(MenuItem(node.widget).checked)
  nimMeth("checked:"):
    let node = MenuItemNode(evalArgInfix(spry))
    let checked = BoolVal(evalArg(spry)).value
    MenuItem(node.widget).checked = checked
    return node

  # Controls
  nimMeth("destroy"):
    let node = WidgetNode(evalArgInfix(spry))
    destroy(Window(node.widget))
    return node
  nimMeth("show"):
    let node = WidgetNode(evalArgInfix(spry))
    show(Window(node.widget))
    return node
  nimMeth("hide"):
    let node = WidgetNode(evalArgInfix(spry))
    hide(Window(node.widget))
    return node

  # Window
  nimFunc("newWindow:width:height:hasBar:"):
    let title = StringVal(evalArg(spry)).value
    let width = IntVal(evalArg(spry)).value
    let height = IntVal(evalArg(spry)).value
    let hasBar = BoolVal(evalArg(spry)).value
    WindowNode(widget: newWindow(title, width, height, hasBar))
  nimMeth("margined:"):
    var node = WidgetNode(evalArgInfix(spry))
    let margined = BoolVal(evalArg(spry)).value
    if node of WindowNode:
      Window(node.widget).margined = margined
    elif node of GroupNode:
      Group(node.widget).margined = margined
    return node
  nimMeth("onClosingShouldClose:"):
    var node = WindowNode(evalArgInfix(spry))
    node.onClosing = Blok(evalArg(spry))
    Window(node.widget).onclosing = proc(): bool {.closure.} =
      var shouldClose = node.onClosing.evalDo(spry)
      return BoolVal(shouldClose).value
    return node
  nimMeth("message:title:"):
    var win = WindowNode(evalArgInfix(spry))
    let description = StringVal(evalArg(spry)).value
    let title = StringVal(evalArg(spry)).value
    Window(win.widget).msgBox(title, description)
    return win
  nimMeth("error:title:"):
    var win = WindowNode(evalArgInfix(spry))
    let description = StringVal(evalArg(spry)).value
    let title = StringVal(evalArg(spry)).value
    Window(win.widget).msgBoxError(title, description)
    return win
  nimFunc("setChild:"):
    let self = WidgetNode(evalArgInfix(spry))
    let child = WidgetNode(evalArg(spry))
    self.setChild(child)
    return self

   # Groups
  nimFunc("newGroup"):
    let title = StringVal(evalArg(spry)).value
    GroupNode(widget: newGroup(title))

  # MultilineEntry
  nimFunc("newMultilineEntryText"):
    MultilineEntryNode(widget: newMultilineEntry())
  nimFunc("newEntryText:onChanged:"):
    let text = StringVal(evalArg(spry)).value
    let blok = Blok(evalArg(spry))
    let entry = newEntry(text, proc() = discard blok.evalDo(spry))
    EntryNode(widget: entry)
  nimMeth("addText:"):
    var node = MultilineEntryNode(evalArgInfix(spry))
    MultilineEntry(node.widget).add(StringVal(evalArg(spry)).value)
    return node
  nimMeth("readonly"):
    let node = WidgetNode(evalArgInfix(spry))    
    newValue(node.readonly)
  nimMeth("readonly:"):
    let node = WidgetNode(evalArgInfix(spry))    
    let readonly = BoolVal(evalArg(spry)).value
    node.readonly(readonly)
    
  nimMeth("onChanged:"):
    var node = MultilineEntryNode(evalArgInfix(spry))
    node.onChanged = Blok(evalArg(spry))
    MultilineEntry(node.widget).onchanged = proc() = discard node.onChanged.evalDo(spry)
    return node

  # Label
  nimFunc("newLabel:"):
    let text = StringVal(evalArg(spry)).value
    let label = newLabel(text)
    LabelNode(widget: label)

  # Boxes
  nimFunc("newVerticalBox"):
    BoxNode(widget: newVerticalBox())
  nimFunc("newHorizontalBox"):
    BoxNode(widget: newHorizontalBox())
  nimMeth("add:stretch:"):
    let node = BoxNode(evalArgInfix(spry))
    let widget = WidgetNode(evalArg(spry)).widget
    let stretchy = BoolVal(evalArg(spry)).value
    let box = Box(node.widget)
    # So... generics of add forces us to do this?
    if widget of Label:
      box.add(Label(widget), stretchy)
    elif widget of Entry:
      box.add(Entry(widget), stretchy)
    elif widget of MultilineEntry:
      box.add(MultilineEntry(widget), stretchy)
    elif widget of ComboBox:
      box.add(ComboBox(widget), stretchy)
    elif widget of Box:
      box.add(Box(widget), stretchy)
    elif widget of Group:
      box.add(Group(widget), stretchy)
    elif widget of Button:
      box.add(Button(widget), stretchy)
    return node
  nimMeth("delete:"):
    var node = BoxNode(evalArgInfix(spry))
    var index = IntVal(evalArg(spry)).value
    Box(node.widget).delete(index)
    return node
  nimMeth("padded"):
    var node = BoxNode(evalArgInfix(spry))
    return newValue(Box(node.widget).padded)
  nimMeth("padded:"):
    var node = BoxNode(evalArgInfix(spry))
    let padded = BoolVal(evalArg(spry)).value
    Box(node.widget).padded = padded
    return node

  # Buttons
  nimFunc("newButton:onClicked:"):
    let label = StringVal(evalArg(spry)).value
    let blok = Blok(evalArg(spry))
    let button = newButton(label, proc() = discard blok.evalDo(spry))
    ButtonNode(widget: button)

  # Text access
  nimMeth("text"):
    let node = WidgetNode(evalArgInfix(spry))    
    newValue(node.text)
  nimMeth("text:"):
    let node = WidgetNode(evalArgInfix(spry))    
    let text = StringVal(evalArg(spry)).value
    node.text(text)
    return node
  nimMeth("title"):
    let node = WidgetNode(evalArgInfix(spry))    
    newValue(node.title)
  nimMeth("title:"):
    let node = WidgetNode(evalArgInfix(spry))    
    let text = StringVal(evalArg(spry)).value
    node.title(text)
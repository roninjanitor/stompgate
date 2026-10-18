import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Quad Cortex bar widget. The icon shows while Cortex Control runs (by default);
// the popup shows/hides the editor, recalls scenes, toggles the tuner and sets
// the QC's audio. Device state comes from the cortex-control-* commands.
// MIDI is one-way: the QC never reports its scene or tuner, so those buttons
// highlight what was last sent, from here or a keybinding (cortex-control-qc
// keeps that state).
Panel {
  id: qc
  moduleName: "cortex-control-omarchy.quad-cortex"
  ipcTarget: "cortex-control-omarchy.quad-cortex"
  manageIpc: false

  readonly property string glyph: "󰥛" // nf-md-sine_wave: a generic audio-signal symbol
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property int pollIntervalSec: {
    var n = parseInt(String(setting("pollIntervalSec", 5)), 10)
    return isFinite(n) ? Math.max(2, Math.min(60, n)) : 5
  }
  // "running": while Cortex Control runs; "connected": also while the QC is on;
  // "always".
  readonly property string showWhen: {
    var v = String(setting("showWhen", "running"))
    return v === "always" || v === "connected" ? v : "running"
  }

  property var status: ({ connected: false, model: "", accessible: false, appInstalled: false, appRunning: false, appWindow: "none" })
  property bool statusKnown: false
  property var checks: []
  property bool doctorRan: false
  property var audio: ({ present: false })
  property var keys: [] // current shortcuts, read from Hyprland via cortex-control --keys
  property var midi: ({ present: false })
  readonly property int lastScene: midi.scene === undefined ? -1 : midi.scene
  readonly property bool tunerOpen: midi.tunerOpen === true
  readonly property int lastMode: midi.mode === undefined ? -1 : midi.mode
  property string pendingVolumeTarget: ""
  property int pendingVolume: 0

  readonly property bool shown: showWhen === "always"
    || (statusKnown && (status.appRunning === true || (showWhen === "connected" && status.connected === true)))
  readonly property bool connected: status.connected === true && status.accessible === true
  readonly property bool isMini: String(status.model || "").indexOf("mini") !== -1
  readonly property var problems: checks.filter(function(c) { return c.level !== "OK" })

  readonly property string title: status.model ? String(status.model).replace("Neural DSP ", "") : "Quad Cortex"
  readonly property string stateText: {
    if (!statusKnown) return "Checking…"
    if (status.connected && !status.accessible) return "No permission to reach the QC"
    if (!status.connected) return status.appRunning ? "Not connected · editor open" : "Not connected"
    return status.appRunning ? "Connected · editor open" : "Connected"
  }
  readonly property string editorLabel: !status.appInstalled ? "Set up"
    : !status.appRunning ? "Open"
    : status.appWindow === "visible" ? "Hide" : "Show"
  readonly property color barIconColor: status.connected && !status.accessible ? urgent
    : connected ? barForeground : Qt.darker(barForeground, 1.55)

  function refreshStatus() { if (!statusProcess.running) statusProcess.running = true }
  function refreshDoctor() { if (!doctorProcess.running) doctorProcess.running = true }
  // The shortcut whose description contains `fragment`, e.g. "Super + Alt + Q".
  function keyFor(fragment) {
    for (var i = 0; i < keys.length; i++) {
      if (String(keys[i].action).indexOf(fragment) !== -1) return keys[i].keys
    }
    return ""
  }

  function withKey(text, fragment) {
    var k = keyFor(fragment)
    return k ? text + " · " + k : text
  }

  function openKeys() {
    run("cortex-control --keys --menu")
    close()
  }

  function refreshDevice() {
    if (!audioProcess.running) audioProcess.running = true
    if (!midiProcess.running) midiProcess.running = true
  }

  function run(command) {
    if (bar) bar.run(command)
  }

  // Fire-and-forget a cortex-control-qc command, then re-read the state.
  function qcCommand(args) {
    run("cortex-control-qc " + args)
    deviceRefreshDelay.restart()
  }

  function editorAction() {
    if (editorLabel === "Hide") run("cortex-control --hide")
    else run("cortex-control --show")
    close()
  }

  function recallScene(index) {
    midi = Object.assign({}, midi, { scene: index }) // highlight now, not after the refresh
    qcCommand("scene " + "ABCDEFGH".charAt(index))
  }

  function setMode(index) {
    midi = Object.assign({}, midi, { mode: index })
    qcCommand("mode " + ["preset", "scene", "stomp"][index])
  }

  function toggleTuner() {
    midi = Object.assign({}, midi, { tunerOpen: !tunerOpen })
    qcCommand("tuner toggle")
  }

  function queueVolume(target, value) {
    pendingVolumeTarget = target
    pendingVolume = Math.round(value * 100)
    volumeDebounce.restart()
  }

  function sceneLabel(index) {
    return isMini ? "ABCD".charAt(index % 4) : "ABCDEFGH".charAt(index)
  }

  visible: shown
  implicitWidth: shown ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight
  onShownChanged: if (!shown && opened) close()

  onOpenedChanged: if (opened) {
    refreshStatus()
    refreshDoctor()
    refreshDevice()
    if (!keysProcess.running) keysProcess.running = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  Process {
    id: statusProcess
    command: ["cortex-control-doctor", "--status"]
    stdout: StdioCollector { id: statusOut; waitForEnd: true }
    onExited: {
      try {
        qc.status = JSON.parse(String(statusOut.text || "{}"))
        qc.statusKnown = true
      } catch (e) {}
    }
  }

  Process {
    id: doctorProcess
    command: ["cortex-control-doctor", "--json"]
    stdout: StdioCollector { id: doctorOut; waitForEnd: true }
    onExited: {
      try {
        qc.checks = JSON.parse(String(doctorOut.text || "{}")).checks || []
        qc.doctorRan = true
      } catch (e) { qc.doctorRan = false }
    }
  }

  Process {
    id: audioProcess
    command: ["cortex-control-qc", "audio-status"]
    stdout: StdioCollector { id: audioOut; waitForEnd: true }
    onExited: {
      try { qc.audio = JSON.parse(String(audioOut.text || "{}")) } catch (e) { qc.audio = { present: false } }
    }
  }

  Process {
    id: midiProcess
    command: ["cortex-control-qc", "midi-status"]
    stdout: StdioCollector { id: midiOut; waitForEnd: true }
    onExited: {
      try { qc.midi = JSON.parse(String(midiOut.text || "{}")) } catch (e) { qc.midi = { present: false } }
    }
  }

  Process {
    id: keysProcess
    command: ["cortex-control", "--keys", "--json"]
    stdout: StdioCollector { id: keysOut; waitForEnd: true }
    onExited: {
      try { qc.keys = JSON.parse(String(keysOut.text || "[]")) } catch (e) { qc.keys = [] }
    }
  }

  Timer { id: deviceRefreshDelay; interval: 400; onTriggered: qc.refreshDevice() }
  Timer { id: volumeDebounce; interval: 150; onTriggered: qc.qcCommand("volume " + qc.pendingVolumeTarget + " " + qc.pendingVolume) }

  Timer {
    // While open, follow changes made elsewhere (pavucontrol, the QC turning on).
    interval: 2000
    repeat: true
    running: qc.opened
    onTriggered: { qc.refreshStatus(); qc.refreshDevice() }
  }

  Timer {
    interval: qc.pollIntervalSec * 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: qc.refreshStatus()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: qc.bar
    text: qc.shown ? qc.glyph : ""
    foreground: qc.barIconColor
    tooltipText: "Quad Cortex: " + qc.stateText
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton) { qc.run("cortex-control --toggle"); qc.refreshStatus() }
      else if (buttonCode === Qt.RightButton) qc.refreshStatus()
      else qc.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: qc
    bar: qc.bar
    open: qc.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(900))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: qc.close()
      onTabRequested: function(direction) { qc.switchPanel(direction) }
      onActivateRequested: qc.editorAction()
      onTextKey: function(t) {
        var n = parseInt(t, 10)
        if (n >= 1 && n <= 8 && qc.connected && qc.midi.present) qc.recallScene(n - 1)
        else if ((t === "t" || t === "T") && qc.connected && qc.midi.present) qc.toggleTuner()
        else if ((t === "m" || t === "M") && qc.connected && qc.midi.present) qc.setMode((qc.lastMode + 1) % 3)
        else if (t === "k" || t === "K") qc.openKeys()
        else if (t === "d" || t === "D") { qc.run("omarchy-launch-floating-terminal-with-presentation cortex-control-doctor"); qc.close() }
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(14)

          // --- Header: status and the editor's show/hide ----------------------
          RowLayout {
            width: parent.width
            spacing: Style.space(10)

            Text {
              text: qc.glyph
              color: qc.status.connected && !qc.status.accessible ? qc.urgent : qc.foreground
              opacity: qc.connected ? 1.0 : 0.5
              font.family: qc.fontFamily
              font.pixelSize: Style.font.display
              Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: Style.space(1)

              Text {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                text: qc.title
                color: qc.foreground
                font.family: qc.fontFamily
                font.pixelSize: Style.font.heading
                elide: Text.ElideRight
              }

              Text {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                text: qc.stateText
                color: qc.dim
                font.family: qc.fontFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
              }
            }

            Button {
              text: qc.editorLabel
              tooltipText: qc.withKey(qc.editorLabel === "Hide" ? "Hide Cortex Control; it keeps running" : "Show Cortex Control", "show or hide")
              foreground: qc.foreground
              fontFamily: qc.fontFamily
              bordered: true
              Layout.alignment: Qt.AlignVCenter
              onClicked: qc.editorAction()
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: qc.statusKnown && !qc.status.connected
            width: parent.width
            text: "Turn the Quad Cortex on. Cortex Control reconnects by itself."
            color: qc.dim
            font.family: qc.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          // --- Scenes and tuner (MIDI) ---------------------------------------
          Column {
            visible: qc.connected
            width: parent.width
            spacing: Style.space(8)

            PanelSectionHeader {
              text: "MODE & SCENES"
              foreground: qc.foreground
              fontFamily: qc.fontFamily
            }

            RowLayout {
              visible: qc.midi.present === true
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: ["Preset", "Scene", "Stomp"]
                delegate: Button {
                  required property string modelData
                  required property int index
                  Layout.fillWidth: true
                  text: modelData
                  selected: qc.lastMode === index
                  tooltipText: qc.withKey("Mode slot " + (index + 1) + ": " + modelData + " unless you reordered modes on the QC. Next mode", "next mode")
                  foreground: qc.foreground
                  fontFamily: qc.fontFamily
                  bordered: true
                  onClicked: qc.setMode(index)
                }
              }
            }

            Text {
              textFormat: Text.PlainText
              visible: !qc.midi.present
              width: parent.width
              text: "Turn on MIDI OVER USB on the QC (Settings › Device › MIDI) to switch scenes from here."
              color: qc.dim
              font.family: qc.fontFamily
              font.pixelSize: Style.font.bodySmall
              wrapMode: Text.WordWrap
            }

            Repeater {
              // Two rows of four: pages I and II on the mini, A-D and E-H otherwise.
              model: qc.midi.present ? 2 : 0
              delegate: RowLayout {
                id: sceneRow
                required property int index
                width: parent.width
                spacing: Style.space(6)

                Text {
                  visible: qc.isMini
                  text: sceneRow.index === 0 ? "I" : "II"
                  color: qc.dim
                  font.family: qc.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  Layout.preferredWidth: Style.space(18)
                }

                Repeater {
                  model: 4
                  delegate: Button {
                    required property int index
                    readonly property int scene: sceneRow.index * 4 + index
                    Layout.fillWidth: true
                    text: qc.sceneLabel(scene)
                    selected: qc.lastScene === scene
                    tooltipText: qc.withKey("Scene " + (qc.isMini ? (scene < 4 ? "I·" : "II·") : "") + qc.sceneLabel(scene) + ". Next scene", "next scene")
                    foreground: qc.foreground
                    fontFamily: qc.fontFamily
                    bordered: true
                    onClicked: qc.recallScene(scene)
                  }
                }
              }
            }

            PanelSectionHeader {
              visible: qc.midi.present === true
              text: "FOOTSWITCHES"
              foreground: qc.foreground
              fontFamily: qc.fontFamily
            }

            Repeater {
              // Same layout as scenes: pages I and II on the mini.
              model: qc.midi.present ? 2 : 0
              delegate: RowLayout {
                id: switchRow
                required property int index
                width: parent.width
                spacing: Style.space(6)

                Text {
                  visible: qc.isMini
                  text: switchRow.index === 0 ? "I" : "II"
                  color: qc.dim
                  font.family: qc.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  Layout.preferredWidth: Style.space(18)
                }

                Repeater {
                  model: 4
                  delegate: Button {
                    required property int index
                    readonly property int footswitch: switchRow.index * 4 + index + 1
                    Layout.fillWidth: true
                    text: qc.sceneLabel(footswitch - 1)
                    tooltipText: qc.withKey("Footswitch " + (qc.isMini ? (footswitch <= 4 ? "I·" : "II·") : "") + qc.sceneLabel(footswitch - 1) + ": acts like the QC's own switch in the current mode", "footswitch " + footswitch)
                    foreground: qc.foreground
                    fontFamily: qc.fontFamily
                    bordered: true
                    onClicked: qc.qcCommand("footswitch " + footswitch)
                  }
                }
              }
            }

            RowLayout {
              visible: qc.midi.present === true
              width: parent.width
              spacing: Style.space(6)

              Button {
                Layout.fillWidth: true
                text: qc.tunerOpen ? "Tuner · on" : "Tuner"
                selected: qc.tunerOpen
                tooltipText: qc.withKey("The QC doesn't report its tuner, so this follows the last press. Tuner", "tuner")
                foreground: qc.foreground
                fontFamily: qc.fontFamily
                bordered: true
                onClicked: qc.toggleTuner()
              }

              Button {
                Layout.fillWidth: true
                text: "Tap tempo"
                tooltipText: qc.withKey("Tap tempo", "tap tempo")
                foreground: qc.foreground
                fontFamily: qc.fontFamily
                bordered: true
                onClicked: qc.qcCommand("tap")
              }
            }
          }

          // --- Audio (PipeWire) -----------------------------------------------
          Column {
            visible: qc.connected && qc.audio.present === true
            width: parent.width
            spacing: Style.space(6)

            RowLayout {
              width: parent.width

              PanelSectionHeader {
                Layout.fillWidth: true
                text: "AUDIO"
                foreground: qc.foreground
                fontFamily: qc.fontFamily
              }

              Text {
                textFormat: Text.PlainText
                text: "Pro Audio"
                color: qc.dim
                font.family: qc.fontFamily
                font.pixelSize: Style.font.caption
                Layout.alignment: Qt.AlignVCenter
              }

              ToggleSwitch {
                checked: qc.audio.proAudio === true
                foreground: qc.foreground
                Layout.alignment: Qt.AlignVCenter
                onToggled: qc.qcCommand("pro-audio " + (qc.audio.proAudio ? "off" : "on"))
              }
            }

            VolumeRow { label: "Out"; target: "output"; node: qc.audio.output || null; width: parent.width }
            VolumeRow { label: "In"; target: "input"; node: qc.audio.input || null; width: parent.width }
          }

          // --- Footer: setup status and the firmware rule ---------------------
          PanelSeparator { foreground: qc.foreground }

          Column {
            visible: qc.problems.length > 0
            width: parent.width
            spacing: Style.space(6)

            Repeater {
              model: qc.problems
              delegate: CheckRow { required property var modelData; check: modelData; width: parent.width }
            }
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(14)

            FooterLink {
              text: !qc.doctorRan ? "Checking…" : qc.problems.length === 0 ? "✓ Setup OK" : "Doctor"
              tooltip: "Full cortex-control-doctor report (d)"
              onActivated: { qc.run("omarchy-launch-floating-terminal-with-presentation cortex-control-doctor"); qc.close() }
            }

            FooterLink {
              text: "Keys"
              tooltip: "Keyboard shortcuts, and where to change them (k)"
              onActivated: qc.openKeys()
            }

            Item { Layout.fillWidth: true }

            Text {
              textFormat: Text.PlainText
              text: "Firmware: Wi‑Fi only"
              color: qc.dim
              font.family: qc.fontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }
      }
    }
  }

  component FooterLink: Text {
    id: link
    property string tooltip: ""
    signal activated()

    textFormat: Text.PlainText
    color: linkArea.containsMouse ? qc.foreground : qc.dim
    font.family: qc.fontFamily
    font.pixelSize: Style.font.caption
    font.underline: linkArea.containsMouse

    MouseArea {
      id: linkArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: link.activated()
    }

    PanelToolTip {
      visible: linkArea.containsMouse && link.tooltip !== ""
      text: link.tooltip
      fontFamily: qc.fontFamily
    }
  }

  component VolumeRow: RowLayout {
    id: volumeRow
    property string label: ""
    property string target: ""
    property var node: null
    readonly property real volume: node ? node.volume / 100 : 0
    readonly property bool muted: node ? node.muted === true : false

    visible: node !== null
    spacing: Style.space(8)

    Text {
      textFormat: Text.PlainText
      text: volumeRow.label
      color: qc.foreground
      font.family: qc.fontFamily
      font.pixelSize: Style.font.bodySmall
      Layout.preferredWidth: Style.space(28)
    }

    PanelSlider {
      id: slider
      bar: qc.bar
      Layout.fillWidth: true
      minimum: 0
      maximum: 1
      step: 0.05
      value: volumeRow.volume
      opacity: volumeRow.muted ? 0.4 : 1.0
      onMoved: function(v) { qc.queueVolume(volumeRow.target, v) }
      onRightClicked: qc.qcCommand("mute " + volumeRow.target)
    }

    Text {
      textFormat: Text.PlainText
      text: volumeRow.muted ? "muted" : Math.round((slider.dragging ? slider.liveValue : volumeRow.volume) * 100) + "%"
      color: qc.dim
      font.family: qc.fontFamily
      font.pixelSize: Style.font.bodySmall
      horizontalAlignment: Text.AlignRight
      Layout.preferredWidth: Style.space(42)
    }
  }

  component CheckRow: RowLayout {
    property var check: ({})
    spacing: Style.space(8)

    Text {
      text: check.level === "WARN" ? "󰀦" : "󰅖" // nf-md-alert / nf-md-close
      color: qc.urgent
      font.family: qc.fontFamily
      font.pixelSize: Style.font.bodySmall
      Layout.alignment: Qt.AlignTop
    }

    Text {
      textFormat: Text.PlainText
      Layout.fillWidth: true
      text: (check.check || "") + ": " + (check.detail || "")
      color: qc.foreground
      font.family: qc.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }
  }
}

import QtQuick 2.6
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as Components
import org.kde.plasma.core 2.0 as PlasmaCore

Components.Label {
    id: lyricsDisplay

    Layout.preferredWidth: 10 * PlasmaCore.Units.gridUnit

    readonly property string noSongMessage: "No song playing!"

    property string display: root.track ? root.track : noSongMessage

    text: display

    horizontalAlignment: Text.AlignHCenter
}

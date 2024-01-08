import QtQuick 2.6
import org.kde.plasma.components 2.0 as Components

Components.Label {
    id: lyricsDisplay

    readonly property string noSongMessage: "No song playing!"

    property string display: root.track ? root.track : noSongMessage

    text: display
}

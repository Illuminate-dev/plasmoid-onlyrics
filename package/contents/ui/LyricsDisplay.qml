import QtQuick 2.6
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as Components
import org.kde.plasma.core 2.0 as PlasmaCore

Components.Label {
    Layout.preferredWidth: 40 * PlasmaCore.Units.gridUnit

    // how close to wait before updating lyrics (i.e. wait until x ms before next line)
    readonly property int rounding: plasmoid.configuration.rounding

    readonly property string noSongMessage: "No song playing!"
    readonly property string noLyricsMessage: "No lyrics available!"
    readonly property string beforeFirstLineMessage: "..."

    property bool foundLyrics: false

    property string display: noSongMessage

    text: display

    horizontalAlignment: Text.AlignHCenter

    property string lastArtist: ""
    property string lastTrack: ""

    property var lyrics: []
    property var timestamps: []

    function update() {
        if (!root.track) {
            display = noSongMessage
            return
        }

        // if song changed go fetch new lyrics
        if (lastArtist != root.artist || lastTrack != root.track) {
            lastArtist = root.artist
            lastTrack = root.track
            getLyrics()
        }

        if (!foundLyrics) {
            display = noLyricsMessage
            return
        }

        let t = root.position
        if (timestamps[0] > t+rounding) {
            display = beforeFirstLineMessage
            return
        }


        for (let idx = 1; idx < timestamps.length; idx++) {
            if (timestamps[idx] > t+rounding) {
                display = lyrics[idx-1]
                return
            }
        }

    }

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: update()
    }

    function getLyrics() {
        if (!root.track) { return }
        if (plasmoid.configuration.apiURL == "none") { return }
        var query = root.track + " " + root.artist
        var url = plasmoid.configuration.apiURL + "?name=" + encodeURIComponent(query)
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var response = JSON.parse(xhr.responseText)

                if (response.length == 0) {
                    foundLyrics = false
                    return
                } else {
                    foundLyrics = true
                }

                lyrics = []
                for (let i = 0; i < response.length; i++) {
                    lyrics.push(response[i].words)
                    timestamps.push(response[i].time)
                }
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

}

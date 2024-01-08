
/*
 * Copyright 2013  Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    property var currentMetadata: mpris2Source.currentData ? mpris2Source.currentData.Metadata : undefined
    property string track: {
        if (!currentMetadata) {
            return ""
        }
        var xesamTitle = currentMetadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle
        }
        // if no track title is given, print out the file name
        var xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
        if (!xesamUrl) {
            return ""
        }
        var lastSlashPos = xesamUrl.lastIndexOf('/')
        if (lastSlashPos < 0) {
            return ""
        }
        var lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
        return decodeURIComponent(lastUrlPart)
    }

    property var mprisSourcesModel: []

    PlasmaCore.DataSource {
        id: mpris2Source

        readonly property string multiplexSource: "@multiplex"
        property string current: multiplexSource

        readonly property var currentData: data[current]

        engine: "mpris2"
        connectedSources: sources

        onSourceAdded: {
            updateMprisSourcesModel()
        }

        onSourceRemoved: {
            // if player is closed, reset to multiplex source
            if (source === current) {
                current = multiplexSource
            }
            updateMprisSourcesModel()
        }
    }

    Component.onCompleted: {
        plasmoid.removeAction("configure");
        mpris2Source.serviceForSource("@multiplex").enableGlobalShortcuts()
        updateMprisSourcesModel()
    }

    function updateMprisSourcesModel () {

        var model = [{
            'text': i18n("Choose player automatically"),
            'icon': 'emblem-favorite',
            'source': mpris2Source.multiplexSource
        }]

        var proxyPIDs = [];  // for things like plasma-browser-integration
        var sources = mpris2Source.sources
        for (var i = 0, length = sources.length; i < length; ++i) {
            var source = sources[i]
            if (source === mpris2Source.multiplexSource) {
                continue
            }

            const playerData = mpris2Source.data[source];
            // source data is removed before its name is removed from the list
            if (!playerData) {
                continue;
            }

            model.push({
                'text': playerData["Identity"],
                'icon': playerData["Desktop Icon Name"] || playerData["DesktopEntry"] || "emblem-music-symbolic",
                'source': source
            });


            if ("kde:pid" in playerData["Metadata"]) {
                var proxyPID = playerData["Metadata"]["kde:pid"];
                if (!proxyPIDs.includes(proxyPID)) {
                    proxyPIDs.push(proxyPID);
                }
            }
        }

        // prefer proxy controls like plasma-browser-integration over browser built-in controls
        model = model.filter( item => {
            if (mpris2Source.data[item["source"]] && "InstancePid" in mpris2Source.data[item["source"]]) {
                return !(proxyPIDs.includes(mpris2Source.data[item["source"]]["InstancePid"]));
            }
            return true;
        });

        root.mprisSourcesModel = model;
    }
    

    width: units.gridUnit * 10
    height: units.gridUnit * 4

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: LyricsDisplay { }

}

/*
  Copyright (C) 2014 Amilcar Santos
  Contact: Amilcar Santos <amilcar.santos@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Amilcar Santos nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

	// allowedOrientations: Orientation.All

	Flickable {
		id: flick
		width: parent.width - Theme.paddingLarge * 2
		height: parent.height
		anchors.centerIn: parent
		contentHeight: transparentBox.height

		Rectangle {
			id: transparentBox
			y: (flick.height - height) / 2
			width: parent.width
			height: parent.width
			clip: true
			color: 'transparent'

			Rectangle {
				rotation: 20
				gradient: Gradient {
					GradientStop {
						position: 0.05;
						color: 'transparent'
					}
					GradientStop {
						position: 1.0;
						color: "#60" + Theme.highlightColor.toString().substring(1)
					}
				}
				anchors.centerIn: parent
				height: flick.width * 1.3
				width: flick.width * 1.3
			}
		}

		Column {
			id: column1
			width: parent.width
			spacing: Theme.paddingMedium
			anchors.centerIn: transparentBox

			Label {
				font.pixelSize: Theme.fontSizeMedium
				text: appname+" v"+version
				anchors.horizontalCenter: parent.horizontalCenter
			}
			Label {
				font.pixelSize: Theme.fontSizeSmall
				text: qsTr("Displays words on the screen with large letters.")
				anchors.horizontalCenter: parent.horizontalCenter
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignHCenter
				height: Theme.fontSizeSmall * 2 + Theme.paddingSmall
				width: parent.width - Theme.paddingMedium * 2
				wrapMode: Text.WordWrap
			}
			Image {
				source: appicon
				height: Theme.itemSizeLarge
				width: Theme.itemSizeLarge
				fillMode: Image.PreserveAspectFit
				anchors.horizontalCenter: parent.horizontalCenter
			}
			Label {
				width: parent.width
				font.pixelSize: Theme.fontSizeTiny
				text: "Developed by:\n Amilcar Santos <amilcar.santos@gmail.com>\n"
					+ "Based on 'Big Word' by\n Pavel Rusin <askold.dalin@gmail.com>\n"
					+ "License: BSD (3-clause)"
				anchors.horizontalCenter: parent.horizontalCenter
				horizontalAlignment: Text.AlignHCenter
				//verticalAlignment: Text.AlignHCenter
				wrapMode: Text.WordWrap
			}
			Button {
				id: homepage
				anchors.horizontalCenter: parent.horizontalCenter
				text: "Sourcecode at Github"
				onClicked: {
					Qt.openUrlExternally(appurl)
					pageStack.pop()
				}
			}
		}
    }
}

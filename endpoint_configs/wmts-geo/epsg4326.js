/**
 * GIBS Web Examples
 *
 * Copyright 2013 - 2014 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

window.onload = function() {

    var map = new ol.Map({
        view: new ol.View({
            maxResolution: 0.5625,
            projection: ol.proj.get("EPSG:4326"),
            extent: [-180, -90, 180, 90],
            center: [0, 0],
            zoom: 2,
            maxZoom: 7
        }),
        target: "map",
        renderer: ["canvas", "dom"]
    });

    var source = new ol.source.WMTS({
        url: "/onearth/demo/wmts/geo/wmts.cgi?",
        layer: "blue_marble",
        format: "image/jpeg",
        matrixSet: "EPSG4326_1km",
        tileGrid: new ol.tilegrid.WMTS({
            origin: [-180, 90],
            resolutions: [
                0.5625,
                0.28125,
                0.140625,
                0.0703125,
                0.03515625,
                0.017578125,
		0.0087890625
            ],
            matrixIds: [0, 1, 2, 3, 4, 5, 6],
            tileSize: 512
        })
    });
    
    var sourceMODIS = new ol.source.WMTS({
        url: "/onearth/demo/wmts/geo/wmts.cgi?",
        layer: "MYR4ODLOLLDY_global_10km",
        format: "image/png",
        matrixSet: "EPSG4326_2km",
        tileGrid: new ol.tilegrid.WMTS({
            origin: [-180, 90],
            resolutions: [
                0.5625,
                0.28125,
                0.140625,
		0.0703125,
		0.03515625
            ],
            matrixIds: [0, 1, 2, 3, 4],
            tileSize: 512
        })
    });

    var layer = new ol.layer.Tile({
        source: source
    });
    
    var layerMODIS = new ol.layer.Tile({
	source: sourceMODIS
    });

    map.addLayer(layer);

    map.addLayer(layerMODIS);
};

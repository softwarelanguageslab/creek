/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./node_modules/css-loader/dist/cjs.js!./src/style.css":
/*!*************************************************************!*\
  !*** ./node_modules/css-loader/dist/cjs.js!./src/style.css ***!
  \*************************************************************/
/***/ ((module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (__WEBPACK_DEFAULT_EXPORT__)\n/* harmony export */ });\n/* harmony import */ var _node_modules_css_loader_dist_runtime_noSourceMaps_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../node_modules/css-loader/dist/runtime/noSourceMaps.js */ \"./node_modules/css-loader/dist/runtime/noSourceMaps.js\");\n/* harmony import */ var _node_modules_css_loader_dist_runtime_noSourceMaps_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_node_modules_css_loader_dist_runtime_noSourceMaps_js__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var _node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../node_modules/css-loader/dist/runtime/api.js */ \"./node_modules/css-loader/dist/runtime/api.js\");\n/* harmony import */ var _node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1__);\n// Imports\n\n\nvar ___CSS_LOADER_EXPORT___ = _node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1___default()((_node_modules_css_loader_dist_runtime_noSourceMaps_js__WEBPACK_IMPORTED_MODULE_0___default()));\n// Module\n___CSS_LOADER_EXPORT___.push([module.id, \"#mynetwork {\\n    /* height: 500px; */\\n    height: 720px;\\n    /* background-color: aliceblue; */\\n}\\n\\nbody {\\n    background-color: #c2c2c200;\\n}\\n\\n.CodeMirror {\\n    height: unset;\\n}\\n\\n#socket {\\n    height: 20px;\\n    width: 20px;\\n    top: 0;\\n    left: 0;\\n    position: absolute;\\n}\\n\\n.streambtn {\\n    margin-left: 2px;\\n    margin-right: 2px;\\n}\\n\\n.field {\\n    font-family: monospace;\\n}\\n\\n.vals {\\n    list-style-type: none;\\n    font-family: monospace;\\n }\\n\\n #history {\\n     height: 488px;\\n     overflow-x:hidden;\\n     overflow-y: auto;;\\n }\\n\\n .text-left >  {\\n    text-align: left;\\n }\\n\\n .text-right >  {\\n    text-align: right;\\n }\\n\\n#out > li {\\n    padding-left: 0px;\\n    text-align: left;\\n}\\n\\nul {\\n    padding-left: 0px;\\n}\\n\\n#in > li {\\n    padding-right: 0px;\\n    text-align: right;\\n}\\n\\n#history > div {\\n    padding-left: 0px;\\n    padding-right: 0px;\\n}\\n\\n.box {\\n    box-shadow: rgba(149, 157, 165, 0.2) 0px 8px 24px;\\n    /* padding: 10px; */\\n    height: 100%;\\n    background-color: white;\\n}\", \"\"]);\n// Exports\n/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (___CSS_LOADER_EXPORT___);\n\n\n//# sourceURL=webpack://debugger/./src/style.css?./node_modules/css-loader/dist/cjs.js");

/***/ }),

/***/ "./node_modules/css-loader/dist/runtime/api.js":
/*!*****************************************************!*\
  !*** ./node_modules/css-loader/dist/runtime/api.js ***!
  \*****************************************************/
/***/ ((module) => {

eval("\n\n/*\n  MIT License http://www.opensource.org/licenses/mit-license.php\n  Author Tobias Koppers @sokra\n*/\nmodule.exports = function (cssWithMappingToString) {\n  var list = []; // return the list of modules as css string\n\n  list.toString = function toString() {\n    return this.map(function (item) {\n      var content = \"\";\n      var needLayer = typeof item[5] !== \"undefined\";\n\n      if (item[4]) {\n        content += \"@supports (\".concat(item[4], \") {\");\n      }\n\n      if (item[2]) {\n        content += \"@media \".concat(item[2], \" {\");\n      }\n\n      if (needLayer) {\n        content += \"@layer\".concat(item[5].length > 0 ? \" \".concat(item[5]) : \"\", \" {\");\n      }\n\n      content += cssWithMappingToString(item);\n\n      if (needLayer) {\n        content += \"}\";\n      }\n\n      if (item[2]) {\n        content += \"}\";\n      }\n\n      if (item[4]) {\n        content += \"}\";\n      }\n\n      return content;\n    }).join(\"\");\n  }; // import a list of modules into the list\n\n\n  list.i = function i(modules, media, dedupe, supports, layer) {\n    if (typeof modules === \"string\") {\n      modules = [[null, modules, undefined]];\n    }\n\n    var alreadyImportedModules = {};\n\n    if (dedupe) {\n      for (var k = 0; k < this.length; k++) {\n        var id = this[k][0];\n\n        if (id != null) {\n          alreadyImportedModules[id] = true;\n        }\n      }\n    }\n\n    for (var _k = 0; _k < modules.length; _k++) {\n      var item = [].concat(modules[_k]);\n\n      if (dedupe && alreadyImportedModules[item[0]]) {\n        continue;\n      }\n\n      if (typeof layer !== \"undefined\") {\n        if (typeof item[5] === \"undefined\") {\n          item[5] = layer;\n        } else {\n          item[1] = \"@layer\".concat(item[5].length > 0 ? \" \".concat(item[5]) : \"\", \" {\").concat(item[1], \"}\");\n          item[5] = layer;\n        }\n      }\n\n      if (media) {\n        if (!item[2]) {\n          item[2] = media;\n        } else {\n          item[1] = \"@media \".concat(item[2], \" {\").concat(item[1], \"}\");\n          item[2] = media;\n        }\n      }\n\n      if (supports) {\n        if (!item[4]) {\n          item[4] = \"\".concat(supports);\n        } else {\n          item[1] = \"@supports (\".concat(item[4], \") {\").concat(item[1], \"}\");\n          item[4] = supports;\n        }\n      }\n\n      list.push(item);\n    }\n  };\n\n  return list;\n};\n\n//# sourceURL=webpack://debugger/./node_modules/css-loader/dist/runtime/api.js?");

/***/ }),

/***/ "./node_modules/css-loader/dist/runtime/noSourceMaps.js":
/*!**************************************************************!*\
  !*** ./node_modules/css-loader/dist/runtime/noSourceMaps.js ***!
  \**************************************************************/
/***/ ((module) => {

eval("\n\nmodule.exports = function (i) {\n  return i[1];\n};\n\n//# sourceURL=webpack://debugger/./node_modules/css-loader/dist/runtime/noSourceMaps.js?");

/***/ }),

/***/ "./src/style.css":
/*!***********************!*\
  !*** ./src/style.css ***!
  \***********************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (__WEBPACK_DEFAULT_EXPORT__)\n/* harmony export */ });\n/* harmony import */ var _node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! !../node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js */ \"./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js\");\n/* harmony import */ var _node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var _node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! !../node_modules/style-loader/dist/runtime/styleDomAPI.js */ \"./node_modules/style-loader/dist/runtime/styleDomAPI.js\");\n/* harmony import */ var _node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1__);\n/* harmony import */ var _node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! !../node_modules/style-loader/dist/runtime/insertBySelector.js */ \"./node_modules/style-loader/dist/runtime/insertBySelector.js\");\n/* harmony import */ var _node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2__);\n/* harmony import */ var _node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! !../node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js */ \"./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js\");\n/* harmony import */ var _node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3__);\n/* harmony import */ var _node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! !../node_modules/style-loader/dist/runtime/insertStyleElement.js */ \"./node_modules/style-loader/dist/runtime/insertStyleElement.js\");\n/* harmony import */ var _node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4__);\n/* harmony import */ var _node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! !../node_modules/style-loader/dist/runtime/styleTagTransform.js */ \"./node_modules/style-loader/dist/runtime/styleTagTransform.js\");\n/* harmony import */ var _node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5__);\n/* harmony import */ var _node_modules_css_loader_dist_cjs_js_style_css__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! !!../node_modules/css-loader/dist/cjs.js!./style.css */ \"./node_modules/css-loader/dist/cjs.js!./src/style.css\");\n\n      \n      \n      \n      \n      \n      \n      \n      \n      \n\nvar options = {};\n\noptions.styleTagTransform = (_node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5___default());\noptions.setAttributes = (_node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3___default());\n\n      options.insert = _node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2___default().bind(null, \"head\");\n    \noptions.domAPI = (_node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1___default());\noptions.insertStyleElement = (_node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4___default());\n\nvar update = _node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0___default()(_node_modules_css_loader_dist_cjs_js_style_css__WEBPACK_IMPORTED_MODULE_6__[\"default\"], options);\n\n\n\n\n       /* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (_node_modules_css_loader_dist_cjs_js_style_css__WEBPACK_IMPORTED_MODULE_6__[\"default\"] && _node_modules_css_loader_dist_cjs_js_style_css__WEBPACK_IMPORTED_MODULE_6__[\"default\"].locals ? _node_modules_css_loader_dist_cjs_js_style_css__WEBPACK_IMPORTED_MODULE_6__[\"default\"].locals : undefined);\n\n\n//# sourceURL=webpack://debugger/./src/style.css?");

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js":
/*!****************************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js ***!
  \****************************************************************************/
/***/ ((module) => {

eval("\n\nvar stylesInDOM = [];\n\nfunction getIndexByIdentifier(identifier) {\n  var result = -1;\n\n  for (var i = 0; i < stylesInDOM.length; i++) {\n    if (stylesInDOM[i].identifier === identifier) {\n      result = i;\n      break;\n    }\n  }\n\n  return result;\n}\n\nfunction modulesToDom(list, options) {\n  var idCountMap = {};\n  var identifiers = [];\n\n  for (var i = 0; i < list.length; i++) {\n    var item = list[i];\n    var id = options.base ? item[0] + options.base : item[0];\n    var count = idCountMap[id] || 0;\n    var identifier = \"\".concat(id, \" \").concat(count);\n    idCountMap[id] = count + 1;\n    var indexByIdentifier = getIndexByIdentifier(identifier);\n    var obj = {\n      css: item[1],\n      media: item[2],\n      sourceMap: item[3],\n      supports: item[4],\n      layer: item[5]\n    };\n\n    if (indexByIdentifier !== -1) {\n      stylesInDOM[indexByIdentifier].references++;\n      stylesInDOM[indexByIdentifier].updater(obj);\n    } else {\n      var updater = addElementStyle(obj, options);\n      options.byIndex = i;\n      stylesInDOM.splice(i, 0, {\n        identifier: identifier,\n        updater: updater,\n        references: 1\n      });\n    }\n\n    identifiers.push(identifier);\n  }\n\n  return identifiers;\n}\n\nfunction addElementStyle(obj, options) {\n  var api = options.domAPI(options);\n  api.update(obj);\n\n  var updater = function updater(newObj) {\n    if (newObj) {\n      if (newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap && newObj.supports === obj.supports && newObj.layer === obj.layer) {\n        return;\n      }\n\n      api.update(obj = newObj);\n    } else {\n      api.remove();\n    }\n  };\n\n  return updater;\n}\n\nmodule.exports = function (list, options) {\n  options = options || {};\n  list = list || [];\n  var lastIdentifiers = modulesToDom(list, options);\n  return function update(newList) {\n    newList = newList || [];\n\n    for (var i = 0; i < lastIdentifiers.length; i++) {\n      var identifier = lastIdentifiers[i];\n      var index = getIndexByIdentifier(identifier);\n      stylesInDOM[index].references--;\n    }\n\n    var newLastIdentifiers = modulesToDom(newList, options);\n\n    for (var _i = 0; _i < lastIdentifiers.length; _i++) {\n      var _identifier = lastIdentifiers[_i];\n\n      var _index = getIndexByIdentifier(_identifier);\n\n      if (stylesInDOM[_index].references === 0) {\n        stylesInDOM[_index].updater();\n\n        stylesInDOM.splice(_index, 1);\n      }\n    }\n\n    lastIdentifiers = newLastIdentifiers;\n  };\n};\n\n//# sourceURL=webpack://debugger/./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js?");

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/insertBySelector.js":
/*!********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/insertBySelector.js ***!
  \********************************************************************/
/***/ ((module) => {

eval("\n\nvar memo = {};\n/* istanbul ignore next  */\n\nfunction getTarget(target) {\n  if (typeof memo[target] === \"undefined\") {\n    var styleTarget = document.querySelector(target); // Special case to return head of iframe instead of iframe itself\n\n    if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {\n      try {\n        // This will throw an exception if access to iframe is blocked\n        // due to cross-origin restrictions\n        styleTarget = styleTarget.contentDocument.head;\n      } catch (e) {\n        // istanbul ignore next\n        styleTarget = null;\n      }\n    }\n\n    memo[target] = styleTarget;\n  }\n\n  return memo[target];\n}\n/* istanbul ignore next  */\n\n\nfunction insertBySelector(insert, style) {\n  var target = getTarget(insert);\n\n  if (!target) {\n    throw new Error(\"Couldn't find a style target. This probably means that the value for the 'insert' parameter is invalid.\");\n  }\n\n  target.appendChild(style);\n}\n\nmodule.exports = insertBySelector;\n\n//# sourceURL=webpack://debugger/./node_modules/style-loader/dist/runtime/insertBySelector.js?");

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/insertStyleElement.js":
/*!**********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/insertStyleElement.js ***!
  \**********************************************************************/
/***/ ((module) => {

eval("\n\n/* istanbul ignore next  */\nfunction insertStyleElement(options) {\n  var element = document.createElement(\"style\");\n  options.setAttributes(element, options.attributes);\n  options.insert(element, options.options);\n  return element;\n}\n\nmodule.exports = insertStyleElement;\n\n//# sourceURL=webpack://debugger/./node_modules/style-loader/dist/runtime/insertStyleElement.js?");

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js":
/*!**********************************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js ***!
  \**********************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

eval("\n\n/* istanbul ignore next  */\nfunction setAttributesWithoutAttributes(styleElement) {\n  var nonce =  true ? __webpack_require__.nc : 0;\n\n  if (nonce) {\n    styleElement.setAttribute(\"nonce\", nonce);\n  }\n}\n\nmodule.exports = setAttributesWithoutAttributes;\n\n//# sourceURL=webpack://debugger/./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js?");

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/styleDomAPI.js":
/*!***************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/styleDomAPI.js ***!
  \***************************************************************/
/***/ ((module) => {

eval("\n\n/* istanbul ignore next  */\nfunction apply(styleElement, options, obj) {\n  var css = \"\";\n\n  if (obj.supports) {\n    css += \"@supports (\".concat(obj.supports, \") {\");\n  }\n\n  if (obj.media) {\n    css += \"@media \".concat(obj.media, \" {\");\n  }\n\n  var needLayer = typeof obj.layer !== \"undefined\";\n\n  if (needLayer) {\n    css += \"@layer\".concat(obj.layer.length > 0 ? \" \".concat(obj.layer) : \"\", \" {\");\n  }\n\n  css += obj.css;\n\n  if (needLayer) {\n    css += \"}\";\n  }\n\n  if (obj.media) {\n    css += \"}\";\n  }\n\n  if (obj.supports) {\n    css += \"}\";\n  }\n\n  var sourceMap = obj.sourceMap;\n\n  if (sourceMap && typeof btoa !== \"undefined\") {\n    css += \"\\n/*# sourceMappingURL=data:application/json;base64,\".concat(btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))), \" */\");\n  } // For old IE\n\n  /* istanbul ignore if  */\n\n\n  options.styleTagTransform(css, styleElement, options.options);\n}\n\nfunction removeStyleElement(styleElement) {\n  // istanbul ignore if\n  if (styleElement.parentNode === null) {\n    return false;\n  }\n\n  styleElement.parentNode.removeChild(styleElement);\n}\n/* istanbul ignore next  */\n\n\nfunction domAPI(options) {\n  var styleElement = options.insertStyleElement(options);\n  return {\n    update: function update(obj) {\n      apply(styleElement, options, obj);\n    },\n    remove: function remove() {\n      removeStyleElement(styleElement);\n    }\n  };\n}\n\nmodule.exports = domAPI;\n\n//# sourceURL=webpack://debugger/./node_modules/style-loader/dist/runtime/styleDomAPI.js?");

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/styleTagTransform.js":
/*!*********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/styleTagTransform.js ***!
  \*********************************************************************/
/***/ ((module) => {

eval("\n\n/* istanbul ignore next  */\nfunction styleTagTransform(css, styleElement) {\n  if (styleElement.styleSheet) {\n    styleElement.styleSheet.cssText = css;\n  } else {\n    while (styleElement.firstChild) {\n      styleElement.removeChild(styleElement.firstChild);\n    }\n\n    styleElement.appendChild(document.createTextNode(css));\n  }\n}\n\nmodule.exports = styleTagTransform;\n\n//# sourceURL=webpack://debugger/./node_modules/style-loader/dist/runtime/styleTagTransform.js?");

/***/ }),

/***/ "./src/index.js":
/*!**********************!*\
  !*** ./src/index.js ***!
  \**********************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony import */ var _style_css__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./style.css */ \"./src/style.css\");\n\n\n\n\nvar editor = CodeMirror.fromTextArea(document.getElementById('editor'), {\n    mode: \"ruby\",\n    lineNumbers: true,\n});\neditor.save()\n\nvar editor2 = CodeMirror.fromTextArea(document.getElementById('editor2'), {\n    mode: \"ruby\",\n    lineNumbers: true,\n});\neditor2.save()\n\nvar stream_cache = {};\nvar operators_cache = {};\nvar current_stream_id = null;\nvar current_node_id = null;\n\n\ndocument.addEventListener('readystatechange', () => {\n    if (document.readyState == 'complete') {\n        // Attach event handler to button\n        const btn = document.querySelector('#updateArgButton');\n        btn.addEventListener('click', handler);\n    }\n});\n\n\n// create an array with nodes\n// var nodes = new vis.DataSet([\n//     { id: 1, label: \"Node 1\" },\n//     { id: 2, label: \"Node 2\" },\n//     { id: 3, label: \"Node 3\" },\n// ]);\nvar nodes = new vis.DataSet([]);\n\nvar emissions = {};\nvar receives = {};\n\n// create an array with edges\n// var edges = new vis.DataSet([\n//     { from: 1, to: 2, label: \"middle\", font: { align: \"middle\" } },\n//     { from: 1, to: 3, label: \"middle\", font: { align: \"middle\" } },\n// ]);\nvar edges = new vis.DataSet([])\nvar container = document.getElementById(\"mynetwork\");\nvar data = {\n    nodes: nodes,\n    edges: edges,\n};\n\nvar options = {\n    layout: {\n        hierarchical: {\n            direction: \"UD\",\n            sortMethod: \"directed\",\n        },\n    },\n    edges: {\n        arrows: \"to\",\n    },\n    nodes: {\n        borderWidth: 15,\n        borderWidthSelected: 15,\n        brokenImage: undefined,\n        chosen: false,\n        color: {\n            border: '#2B7CE9',\n            background: '#2B7CE9',\n            highlight: {\n                border: '#2B7CE9',\n                background: '#2B7CE9'\n            },\n            hover: {\n                border: '#2B7CE9',\n                background: '#2B7CE9'\n            }\n        }\n    }\n};\nvar network = new vis.Network(container, data, options);\n\nvar selected_node = null;\nvar selected_edge = null;\n\nfunction updateNodeDetails() {\n    if (selected_node == null) {\n        return;\n    }\n    var node = nodes.get(selected_node);\n    var node_id = node.id;\n    current_node_id = node_id;\n    var node_label = node.label;\n\n    console.log(operators_cache);\n    var operator = operators_cache[node_id];\n    document.getElementById(\"node_id\").textContent = node_id;\n    document.getElementById(\"node_name\").textContent = operator.name;\n    document.getElementById(\"node_pid\").textContent = operator.pid;\n    document.getElementById(\"node_arity\").textContent = `${operator.in}:${operator.out}`;\n\n    if (operator.hasOwnProperty('state')) {\n        editor.doc.setValue(operator.state);\n    }\n    else {\n        editor.doc.setValue(\"n/a\");\n\n    }\n    editor2.doc.setValue(operator.arg);\n\n    document.getElementById(\"in\").innerHTML = '';\n    document.getElementById(\"out\").innerHTML = '';\n\n    if (emissions.hasOwnProperty(node_id)) {\n        emissions[node_id].forEach(emission => {\n            addEmissionOut(emission);\n        })\n    }\n\n    if (receives.hasOwnProperty(node_id)) {\n        receives[node_id].forEach(emission => {\n            addEmissionIn(emission);\n        })\n    }\n\n\n\n    document.getElementById(\"node_data\").style.display = \"flex\";\n    document.getElementById(\"node_data2\").style.display = \"flex\";\n    document.getElementById(\"history\").style.display = \"flex\";\n    document.getElementById(\"edge_data\").style.display = \"none\";\n\n    editor.refresh()\n    editor2.refresh()\n};\nfunction updateEdgeDetails() {\n    console.log(`Clicked on edge ${selected_edge}`);\n\n    var edge = edges.get(selected_edge);\n    var edge_id = edge.id;\n    var edge_label = edge.label;\n\n    setLabelEdge(edge_id);\n\n    document.getElementById(\"edge_id\").textContent = edge_id;\n    document.getElementById(\"edge_label\").textContent = edge_label;\n\n    document.getElementById(\"node_data\").style.display = \"none\";\n    document.getElementById(\"node_data2\").style.display = \"none\";\n    document.getElementById(\"edge_data\").style.display = \"none\";\n    document.getElementById(\"edge_data\").style.display = \"flex\";\n};\n\nfunction setLabelEdge(edge_id, label) {\n    var edge = edges.get(edge_id);\n    var from = edge.from;\n    var to = edge.to;\n    edges.update({ id: edge.id, from: from, to: to, label: label });\n}\n\nfunction terminateNode(node_id) {\n    var node = nodes.get(node_id);\n\n    node.color = {\n        border: 'red',\n        background: 'red',\n        highlight: {\n            border: 'red',\n            background: 'red'\n        }\n    };\n    nodes.update(node);\n}\n\nfunction completeNode(pid) {\n    for (const stream_id in stream_cache) {\n        var stream = stream_cache[stream_id];\n\n        for (var i = 0; i < stream.length; i++) {\n            var edge = stream[i];\n            if (edge.from.pid == pid) {\n                edge.from.status = \"complete\";\n            }\n            if (edge.to.pid == pid) {\n                edge.to.status = \"complete\";\n            }\n        }\n    }\n\n    // rerender details..\n    if (selected_node == pid) {\n        updateNodeDetails();\n    }\n}\n\n\nnetwork.on(\"click\", function (params) {\n    socketOff();\n    if (params.nodes != null && params.nodes.length > 0) {\n        selected_node = params.nodes[0];\n        updateNodeDetails();\n        return;\n    }\n    if (params.edges != null && params.edges.length > 0) {\n        selected_edge = params.edges[0];\n        updateEdgeDetails();\n        return;\n    }\n});\n\nfunction socketOn() {\n    document.getElementById(\"socket_off\").style.removeProperty(\"display\");\n    document.getElementById(\"socket_on\").style.display = \"none\";\n}\nfunction socketOff() {\n    document.getElementById(\"socket_on\").style.removeProperty(\"display\");\n    document.getElementById(\"socket_off\").style.display = \"none\";\n}\n\n\nfunction rebuildOpratorCache() {\n    if (current_stream_id == null) {\n        operators_cache = {};\n    }\n    else {\n        var streamid = current_stream_id;\n        var stream = stream_cache[streamid];\n\n        operators_cache = {};\n        nodes.clear();\n        edges.clear();\n\n        stream.forEach(edge => {\n            var from = { id: edge.from.pid, label: edge.from.name }\n            var to = { id: edge.to.pid, label: edge.to.name }\n            var edg = { from: from.id, to: to.id, label: \"\" }\n            operators_cache[edge.from.pid] = edge.from;\n            operators_cache[edge.to.pid] = edge.to;\n\n            if (edge.from.hasOwnProperty(\"status\")) {\n                console.log(\"completed found!\")\n                if (edge.from.status === \"complete\") {\n                    console.log(\"completed node!\")\n                    from.color = {\n                        border: 'green',\n                        background: 'green',\n                        highlight: {\n                            border: 'green',\n                            background: 'green'\n                        }\n                    };\n                }\n            }\n\n            if (edge.to.hasOwnProperty(\"status\")) {\n                console.log(\"completed found!\")\n                if (edge.to.status === \"complete\") {\n                    console.log(\"completed node!\")\n                    to.color = {\n                        border: 'green',\n                        background: 'green',\n                        highlight: {\n                            border: 'green',\n                            background: 'green'\n                        }\n                    };\n                }\n            }\n            nodes.update(from);\n            nodes.update(to);\n            edges.update(edg);\n        });\n    }\n}\nfunction streamClick(event) {\n    var streamid = event.target.innerHTML.substring(7);\n    // var stream = stream_cache[streamid];\n    current_stream_id = streamid;\n    rebuildOpratorCache();\n    network.setOptions(options);\n\n}\n\nfunction addStreamButton(stream_id) {\n    var streams = document.getElementById(\"streamlist\");\n    var btn = document.createElement(\"button\");\n    btn.setAttribute(\"type\", \"button\");\n    btn.setAttribute(\"class\", \"streambtn btn btn-primary\");\n    btn.onclick = streamClick;\n    btn.innerHTML = `Stream ${stream_id}`;\n    streams.appendChild(btn);\n}\n\nfunction addEmissionOut(value) {\n    var btn = document.createElement(\"li\");\n    btn.innerHTML = `${value.value}`;\n    document.getElementById('out').appendChild(btn);\n}\nfunction addEmissionIn(value) {\n    var btn = document.createElement(\"li\");\n    var valstr = \"\" + value.value;\n    btn.innerHTML = `${value.time.toLocaleTimeString()} :: ${valstr.padEnd(8, \"&nbsp; \")}&nbsp;->&nbsp;`;\n    document.getElementById('in').appendChild(btn);\n}\nlet socket = new WebSocket(\"ws://localhost:4000/ws\");\n\n// Define an event handler function\nconst handler = (e) => {\n\n    console.log(current_node_id)\n    if(current_node_id != null) {\n        var m = {\"message\": \"update_arg\", \"arg\": editor.getValue(), \"for\": current_node_id};\n        console.log(editor.getValue())\n        socket.send(JSON.stringify(m));\n    }\n};\n\n\nsocket.onopen = function (e) {\n    socketOn();\n};\n\nsocket.onmessage = function (event) {\n    socketOn();\n    var payload = JSON.parse(event.data);\n    handleServerEvent(payload);\n};\n\nsocket.onclose = function (event) {\n    socketOff();\n    if (event.wasClean) {\n        console.log(`Connection closed cleanly, code=${event.code} reason=${event.reason}`);\n    } else {\n        console.log('Connection died abruptly!');\n    }\n};\n\nsocket.onerror = function (error) {\n    socketOff();\n    alert(`Socket error ${error.message}`);\n};\n\nfunction nodeForPid(pid) {\n    if (current_stream_id == null) {\n        return null;\n    }\n\n    var current_stream = stream_cache[current_stream_id];\n    var found = null;\n    for (let i = 0; i < current_stream.length; i++) {\n        var edge = current_stream[i]\n        if (edge.from.pid == pid) {\n            found = edge.from;\n            return found;\n        }\n        if (edge.to.pid == pid) {\n            found = edge.to;\n            return found;\n        }\n    }\n    return null;\n}\n\nfunction outgoingEdges(pid) {\n    var outEdges = [];\n    edges.forEach(edge => {\n        if (edge.from == pid) {\n            outEdges.push(edge);\n        }\n    });\n    return outEdges;\n}\n\nfunction updateNodeState(pid, state) {\n    for (const stream_id in stream_cache) {\n        var stream = stream_cache[stream_id];\n\n        for (var i = 0; i < stream.length; i++) {\n            var edge = stream[i];\n            if (edge.from.pid == pid) {\n                edge.from.state = state;\n            }\n            if (edge.to.pid == pid) {\n                edge.to.state = state;\n            }\n        }\n    }\n\n    // rerender details..\n    if (selected_node == pid) {\n        updateNodeDetails();\n    }\n\n\n}\nfunction handleServerEvent(event) {\n    if (event.message == \"streamlist\") {\n        nodes.clear();\n        edges.clear();\n\n        stream_cache = event.streams;\n        for (const key in event.streams) {\n            addStreamButton(key);\n        }\n    }\n\n    if (event.message == \"new_stream\") {\n        stream_cache[event.id] = event.stream;\n        addStreamButton(event.id);\n    }\n\n\n    if (event.message == \"outgoing\") {\n        updateNodeState(event.pid, event.state);\n        var node = nodeForPid(event.pid);\n\n        if (emissions.hasOwnProperty(event.pid)) {\n            emissions[event.pid].push({ 'value': event.value, 'time': new Date() });\n        }\n        else {\n            emissions[event.pid] = [{ 'value': event.value, 'time': new Date() }];\n        }\n\n\n        updateNodeDetails();\n\n        if (node != null) {\n            var outEdges = outgoingEdges(event.pid);\n            outEdges.forEach(edge => {\n                setLabelEdge(edge.id, event.value);\n            });\n\n        }\n        else {\n            console.log(\"Node not part of current stream.\")\n        }\n\n        // nodeEmitted(found.pid, event.value);\n    }\n\n\n    if (event.message == \"incoming\") {\n        // updateNodeState(event.pid, event.state);\n        if (receives.hasOwnProperty(event.pid)) {\n            receives[event.pid].push({ 'value': event.value, 'time': new Date() });\n        }\n        else {\n            receives[event.pid] = [{ 'value': event.value, 'time': new Date() }];\n        }\n\n        updateNodeDetails();\n    }\n\n\n    if (event.message == \"update\") {\n        console.log(event);\n        updateNodeState(event.pid, event.state);\n        updateNodeDetails();\n    }\n\n\n    if (event.message == \"complete\") {\n        console.log(event);\n        completeNode(event.pid);\n        rebuildOpratorCache();\n        updateNodeDetails();\n    }\n}\n\n//# sourceURL=webpack://debugger/./src/index.js?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			id: moduleId,
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module can't be inlined because the eval devtool is used.
/******/ 	var __webpack_exports__ = __webpack_require__("./src/index.js");
/******/ 	
/******/ })()
;
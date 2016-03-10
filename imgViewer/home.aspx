<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="home.aspx.cs" Inherits="imgViewer.home" %>

<!doctype html>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>home - img</title>
    <link href="kindeditor-4.1.10/themes/default/default.css" rel="stylesheet" />
    <style type="text/css">
        .ke-statusbar {
            display: none;
        }

        .copyUrl {
            position: fixed;
            top: 0;
            right: 0;
            width: 50%;
            background-color: #999;
            height: auto;
            opacity: 0.9;
        }

        .input_url {
            width: 100%;
            color: #f90;
        }

        .imgDiv {
            float: left;
            padding: 10px;
        }

        .menuer {
            padding: 8px;
            padding-top: 0;
        }
    </style>
</head>
<body>
    <div class="menuer">
        <input id="selectImage" type="button" value="批量上传" />
        <input id="filemanager" type="button" value="素材仓库" />
        <input type="button" onclick="javascript: toRefresh()" value="刷新数据" />
    </div>
    <div runat="server" id="urlList"></div>
    <div class="copyUrl">
        <input type="text" id="input_url" class="input_url" value="travel Control" />
    </div>
</body>
</html>
<script src="kindeditor-4.1.10/kindeditor-all.js" type="text/javascript"></script>
<script src="kindeditor-4.1.10/lang/zh_CN.js" type="text/javascript"></script>

<script type="text/javascript">

    KindEditor.ready(function (K) {
        var editor = K.editor({
            uploadJson: '../action/upload_json.ashx',
            fileManagerJson: '../action/file_manager_json.ashx',
            allowFileManager: true
        });
        K('#selectImage').click(function () {
            editor.loadPlugin('multiimage', function () {
                editor.plugin.multiImageDialog({
                    clickFn: function (urlList) {
                        var div = K('#selectImage');
                        div.html('');
                        K.each(urlList, function (i, data) {
                            div.append('<img src="' + data.url + '">');
                        });
                        editor.hideDialog();
                    }
                });
            });
        }), K('#filemanager').click(function () {
            editor.loadPlugin('filemanager', function () {
                editor.plugin.filemanagerDialog({
                    viewType: 'VIEW',
                    dirName: 'imageList',
                    clickFn: function (url, title) {
                        K('#url').val(url);
                        editor.hideDialog();
                    }
                });
            });
        });
    });

    var getUrl = function (imgUrl) {
        document.getElementById("input_url").value = imgUrl;
        document.getElementById("input_url").select();
    };

    var toRefresh = function () {
        document.location.reload();
    };

</script>

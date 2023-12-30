// 巨大画像のアップロードを防止する
document.addEventListener("turbo:load", function() {
    document.addEventListener("change", function(event) {
        let image_upload = document.querySelector('#micropost_image');
        // イメージアップロード要素がない場合のエラーハンドリング
        if (!image_upload) {
            return;
        }
        const size_in_megabytes = image_upload.files[0].size/1024/1024;
        if (size_in_megabytes > 5) {
            alert("Maxmum file size is 5MB. Please chooose a smaller file.");
            image_upload.value = '';
        }
    });
});
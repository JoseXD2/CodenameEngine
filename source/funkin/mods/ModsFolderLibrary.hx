package funkin.mods;

import lime.utils.AssetLibrary;
import lime.utils.Assets as LimeAssets;

import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.text.Font;
import lime.utils.Bytes;

#if MOD_SUPPORT
import sys.FileStat;
import sys.FileSystem;
#end

using StringTools;

class ModsFolderLibrary extends AssetLibrary implements ModsAssetLibrary {
    public var folderPath:String;
    public var libName:String;
    public var useImageCache:Bool = true;
    public var prefix = 'assets/';

    public function new(folderPath:String, libName:String) {
        this.folderPath = folderPath;
        this.libName = libName;
        this.prefix = 'assets/$libName/';
        super();
    }

    #if MOD_SUPPORT
    private var editedTimes:Map<String, Float> = [];
    public var _parsedAsset:String = null;

    public function getEditedTime(asset:String):Null<Float> {
        return editedTimes[asset];
    }

    public override function getAudioBuffer(id:String):AudioBuffer {
        if (__isCacheValid(LimeAssets.cache.audio, id)) {
            trace("CACHE FOUND!!");
            return LimeAssets.cache.audio.get('$libName:$id');
        }
        else {
            if (!exists(id, "SOUND")) 
                return null;
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(SUtil.getStorageDirectory() + path).mtime.getTime();
            var e = AudioBuffer.fromFile(path);
            // LimeAssets.cache.audio.set('$libName:$id', e);
            return e;
        }
    }

    public override function getBytes(id:String):Bytes {
        if (__isCacheValid(cachedBytes, id, true))
            return cachedBytes.get(id);
        else {
            if (!exists(id, "BINARY"))
                return null;
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(SUtil.getStorageDirectory() + path).mtime.getTime();
            var e = Bytes.fromFile(path);
            cachedBytes.set(id, e);
            return e;
        }
    }

    public override function getFont(id:String):Font {
        if (__isCacheValid(LimeAssets.cache.font, id))
            return LimeAssets.cache.font.get(id);
        else {
            if (!exists(id, "FONT"))
                return null;
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(SUtil.getStorageDirectory() + path).mtime.getTime();
            var e = Font.fromFile(path);
            return e;
        }
    }

    public override function getImage(id:String):Image {
        if (useImageCache && __isCacheValid(LimeAssets.cache.image, id))
            return LimeAssets.cache.image.get('$libName:$id');
        else {
            if (!exists(id, "IMAGE"))
                return null;
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(SUtil.getStorageDirectory() + path).mtime.getTime();

            var e = Image.fromFile(path);
            return e;
        }
    }

    public override function getPath(id:String):String {
        if (!__parseAsset(id)) return null;
        return getAssetPath();
    }

    public function getFiles(folder:String):Array<String> {
        if (!folder.endsWith("/")) folder = folder + "/";
        if (!__parseAsset(folder)) return [];
        var path = getAssetPath();
        try {
            var result:Array<String> = [];
            for(e in FileSystem.readDirectory(SUtil.getStorageDirectory() + path))
                if (!FileSystem.isDirectory(SUtil.getStorageDirectory() + '$path$e'))
                    result.push(e);
            return result;
        } catch(e) {
            // woops!!
        }
        return [];
    }

    public override function exists(asset:String, type:String):Bool { 
        if(!__parseAsset(asset)) return false;
        return FileSystem.exists(getAssetPath());
    }

    private function getAssetPath() {
        return '$folderPath/$_parsedAsset';
    }

    private function __isCacheValid(cache:Map<String, Dynamic>, asset:String, isLocalCache:Bool = false) {
        if (!editedTimes.exists(asset))
            return false;
        if (editedTimes[asset] == null) return false;
        if (editedTimes[asset] < FileSystem.stat(SUtil.getStorageDirectory() + getPath(asset)).mtime.getTime()) return false;

        if (!isLocalCache) asset = '$libName:$asset';

        return cache.exists(asset) && cache[asset] != null;
    }

    private function __parseAsset(asset:String):Bool {
        if (!asset.startsWith(prefix)) return false;
        _parsedAsset = asset.substr(prefix.length);
        return true;
    }
    #end
}

//
//  MimeTypes.swift
//  agsChat
//
//  Created by MAcBook on 03/11/22.
//

import Foundation
import UniformTypeIdentifiers

internal let DEFAULT_MIME_TYPE = "application/octet-stream"

internal let mimeTypes = [
    "html":     "text/html",
    "htm":      "text/html",
    "shtml":    "text/html",
    "css":      "text/css",
    "xml":      "text/xml",
    "gif":      "image/gif",
    "jpeg":     "image/jpeg",
    "jpg":      "image/jpeg",
    "js":       "application/javascript",
    "atom":     "application/atom+xml",
    "rss":      "application/rss+xml",
    "mml":      "text/mathml",
    "txt":      "text/plain",
    "jad":      "text/vnd.sun.j2me.app-descriptor",
    "wml":      "text/vnd.wap.wml",
    "htc":      "text/x-component",
    "png":      "image/png",
    "tif":      "image/tiff",
    "tiff":     "image/tiff",
    "wbmp":     "image/vnd.wap.wbmp",
    "ico":      "image/x-icon",
    "jng":      "image/x-jng",
    "bmp":      "image/x-ms-bmp",
    "svg":      "image/svg+xml",
    "svgz":     "image/svg+xml",
    "webp":     "image/webp",
    "woff":     "application/font-woff",
    "jar":      "application/java-archive",
    "war":      "application/java-archive",
    "ear":      "application/java-archive",
    "json":     "application/json",
    "hqx":      "application/mac-binhex40",
    "doc":      "application/msword",
    "pdf":      "application/pdf",
    "ps":       "application/postscript",
    "eps":      "application/postscript",
    "ai":       "application/postscript",
    "rtf":      "application/rtf",
    "m3u8":     "application/vnd.apple.mpegurl",
    "xls":      "application/vnd.ms-excel",
    "eot":      "application/vnd.ms-fontobject",
    "ppt":      "application/vnd.ms-powerpoint",
    "wmlc":     "application/vnd.wap.wmlc",
    "kml":      "application/vnd.google-earth.kml+xml",
    "kmz":      "application/vnd.google-earth.kmz",
    "7z":       "application/x-7z-compressed",
    "cco":      "application/x-cocoa",
    "jardiff":  "application/x-java-archive-diff",
    "jnlp":     "application/x-java-jnlp-file",
    "run":      "application/x-makeself",
    "pl":       "application/x-perl",
    "pm":       "application/x-perl",
    "prc":      "application/x-pilot",
    "pdb":      "application/x-pilot",
    "rar":      "application/x-rar-compressed",
    "rpm":      "application/x-redhat-package-manager",
    "sea":      "application/x-sea",
    "swf":      "application/x-shockwave-flash",
    "sit":      "application/x-stuffit",
    "tcl":      "application/x-tcl",
    "tk":       "application/x-tcl",
    "der":      "application/x-x509-ca-cert",
    "pem":      "application/x-x509-ca-cert",
    "crt":      "application/x-x509-ca-cert",
    "xpi":      "application/x-xpinstall",
    "xhtml":    "application/xhtml+xml",
    "xspf":     "application/xspf+xml",
    "zip":      "application/zip",
    "epub":     "application/epub+zip",
    "docx":     "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "xlsx":     "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "pptx":     "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "mid":      "audio/midi",
    "midi":     "audio/midi",
    "kar":      "audio/midi",
    "mp3":      "audio/mpeg",
    "ogg":      "audio/ogg",
    "m4a":      "audio/x-m4a",
    "ra":       "audio/x-realaudio",
    "3gpp":     "video/3gpp",
    "3gp":      "video/3gpp",
    "ts":       "video/mp2t",
    "mp4":      "video/mp4",
    "mpeg":     "video/mpeg",
    "mpg":      "video/mpeg",
    "mov":      "video/quicktime",
    "webm":     "video/webm",
    "flv":      "video/x-flv",
    "m4v":      "video/x-m4v",
    "mng":      "video/x-mng",
    "asx":      "video/x-ms-asf",
    "asf":      "video/x-ms-asf",
    "wmv":      "video/x-ms-wmv",
    "avi":      "video/x-msvideo"
]

let docsTypes = ["public.text",
                 "com.apple.iwork.pages.pages",
                 "public.data",
                 "kUTTypeItem",
                 "kUTTypeContent",
                 "kUTTypeCompositeContent",
                 "kUTTypeData",
                 "public.database",
                 "public.calendar-event",
                 "public.message",
                 "public.presentation",
                 "public.contact",
                 "public.archive",
                 "public.disk-image",
                 "public.plain-text",
                 "public.utf8-plain-text",
                 "public.utf16-external-plain-​text",
                 "public.utf16-plain-text",
                 "com.apple.traditional-mac-​plain-text",
                 "public.rtf",
                 "com.apple.ink.inktext",
                 "public.html",
                 "public.xml",
                 "public.source-code",
                 "public.c-source",
                 "public.objective-c-source",
                 "public.c-plus-plus-source",
                 "public.objective-c-plus-​plus-source",
                 "public.c-header",
                 "public.c-plus-plus-header",
                 "com.sun.java-source",
                 "public.script",
                 "public.assembly-source",
                 "com.apple.rez-source",
                 "public.mig-source",
                 "com.apple.symbol-export",
                 "com.netscape.javascript-​source",
                 "public.shell-script",
                 "public.csh-script",
                 "public.perl-script",
                 "public.python-script",
                 "public.ruby-script",
                 "public.php-script",
                 "com.sun.java-web-start",
                 "com.apple.applescript.text",
                 "com.apple.applescript.​script",
                 "public.object-code",
                 "com.apple.mach-o-binary",
                 "com.apple.pef-binary",
                 "com.microsoft.windows-​executable",
                 "com.microsoft.windows-​dynamic-link-library",
                 "com.sun.java-class",
                 "com.sun.java-archive",
                 "com.apple.quartz-​composer-composition",
                 "org.gnu.gnu-tar-archive",
                 "public.tar-archive",
                 "org.gnu.gnu-zip-archive",
                 "org.gnu.gnu-zip-tar-archive",
                 "com.apple.binhex-archive",
                 "com.apple.macbinary-​archive",
                 "public.url",
                 "public.file-url",
                 "public.url-name",
                 "public.vcard",
                 "public.image",
                 "public.fax",
                 "public.jpeg",
                 "public.jpeg-2000",
                 "public.tiff",
                 "public.camera-raw-image",
                 "com.apple.pict",
                 "com.apple.macpaint-image",
                 "public.png",
                 "public.xbitmap-image",
                 "com.apple.quicktime-image",
                 "com.apple.icns",
                 "com.apple.txn.text-​multimedia-data",
                 "public.audiovisual-​content",
                 "public.movie",
                 "public.video",
                 "com.apple.quicktime-movie",
                 "public.avi",
                 "public.mpeg",
                 "public.mpeg-4",
                 "public.3gpp",
                 "public.3gpp2",
                 "public.audio",
                 "public.mp3",
                 "public.mpeg-4-audio",
                 "com.apple.protected-​mpeg-4-audio",
                 "public.ulaw-audio",
                 "public.aifc-audio",
                 "public.aiff-audio",
                 "com.apple.coreaudio-​format",
                 "public.directory",
                 "public.folder",
                 "public.volume",
                 "com.apple.package",
                 "com.apple.bundle",
                 "public.executable",
                 "com.apple.application",
                 "com.apple.application-​bundle",
                 "com.apple.application-file",
                 "com.apple.deprecated-​application-file",
                 "com.apple.plugin",
                 "com.apple.metadata-​importer",
                 "com.apple.dashboard-​widget",
                 "public.cpio-archive",
                 "com.pkware.zip-archive",
                 "com.apple.webarchive",
                 "com.apple.framework",
                 "com.apple.rtfd",
                 "com.apple.flat-rtfd",
                 "com.apple.resolvable",
                 "public.symlink",
                 "com.apple.mount-point",
                 "com.apple.alias-record",
                 "com.apple.alias-file",
                 "public.font",
                 "public.truetype-font",
                 "com.adobe.postscript-font",
                 "com.apple.truetype-​datafork-suitcase-font",
                 "public.opentype-font",
                 "public.truetype-ttf-font",
                 "public.truetype-collection-​font",
                 "com.apple.font-suitcase",
                 "com.adobe.postscript-lwfn​-font",
                 "com.adobe.postscript-pfb-​font",
                 "com.adobe.postscript.pfa-​font",
                 "com.apple.colorsync-profile",
                 "public.filename-extension",
                 "public.mime-type",
                 "com.apple.ostype",
                 "com.apple.nspboard-type",
                 "com.adobe.pdf",
                 "com.adobe.postscript",
                 "com.adobe.encapsulated-​postscript",
                 "com.adobe.photoshop-​image",
                 "com.adobe.illustrator.ai-​image",
                 "com.compuserve.gif",
                 "com.microsoft.bmp",
                 "com.microsoft.ico",
                 "com.microsoft.word.doc",
                 "com.microsoft.excel.xls",
                 "com.microsoft.powerpoint.​ppt",
                 "com.microsoft.waveform-​audio",
                 "com.microsoft.advanced-​systems-format",
                 "com.microsoft.windows-​media-wm",
                 "com.microsoft.windows-​media-wmv",
                 "com.microsoft.windows-​media-wmp",
                 "com.microsoft.windows-​media-wma",
                 "com.microsoft.advanced-​stream-redirector",
                 "com.microsoft.windows-​media-wmx",
                 "com.microsoft.windows-​media-wvx",
                 "com.microsoft.windows-​media-wax",
                 "com.apple.keynote.key",
                 "com.apple.keynote.kth",
                 "com.truevision.tga-image",
                 "com.sgi.sgi-image",
                 "com.ilm.openexr-image",
                 "com.kodak.flashpix.image",
                 "com.j2.jfx-fax",
                 "com.js.efx-fax",
                 "com.digidesign.sd2-audio",
                 "com.real.realmedia",
                 "com.real.realaudio",
                 "com.real.smil",
                 "com.allume.stuffit-archive",
                 "org.openxmlformats.wordprocessingml.document",
                 "com.microsoft.powerpoint.​ppt",
                 "org.openxmlformats.presentationml.presentation",
                 "com.microsoft.excel.xls",
                 "org.openxmlformats.spreadsheetml.sheet",
]

internal func MimeType(ext: String?) -> String {
    return mimeTypes[ext?.lowercased() ?? "" ] ?? DEFAULT_MIME_TYPE
}

//extension NSURL {
//    public func mimeType() -> String {
//        return MimeType(ext: self.pathExtension)
//    }
//}
//
//extension URL {
//    public func mimeType() -> String {
//        return MimeType(ext: self.pathExtension)
//    }
//}
//
//extension NSString {
//    public func mimeType() -> String {
//        return MimeType(ext: self.pathExtension)
//    }
//}
//
//extension String {
//    public func mimeType() -> String {
//        return (self as NSString).mimeType()
//    }
//}

extension NSURL 
{
    public func mimeType() -> String {
        
        if #available(iOS 14.0, *) 
        {
            if let pathExt = self.pathExtension,
               let mimeType = UTType(filenameExtension: pathExt)?.preferredMIMEType 
            {
                return mimeType
            }
            else 
            {
                return "application/octet-stream"
            }
        } 
        else
        {   /*Fallback on earlier versions*/    }
        
        return "application/octet-stream"
    }
}

extension URL 
{
    public func mimeType() -> String 
    {
        if #available(iOS 14.0, *) 
        {
            if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType 
            {
                return mimeType
            }
            else 
            {
                return "application/octet-stream"
            }
        } 
        else
        {   /*Fallback on earlier versions*/  }
        
        return "application/octet-stream"
    }
}

extension NSString 
{
    public func mimeType() -> String 
    {
        if #available(iOS 14.0, *) 
        {
            if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType 
            {
                return mimeType
            }
            else 
            {
                return "application/octet-stream"
            }
        } 
        else
        {   /*Fallback on earlier versions*/    }
        
        return "application/octet-stream"
    }
}

extension String 
{
    public func mimeType() -> String 
    {
        return (self as NSString).mimeType()
    }
}

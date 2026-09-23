package foxlite;

class FoxLog {
	public static function log(origin:String, message:String):Void {
		trace('[FoxLite > $origin]: $message');
	}

	public static function warning(origin:String, message:String):Void {
		trace('[FoxLite > $origin] WARNING: $message');
	}
}
#!/bin/bash
#---------------------------------------------
# Script to start GeoGebra
#---------------------------------------------

#---------------------------------------------
# Used environment variables:
#
# GG_SCRIPTNAME=<name of originally called script to start GeoGebra> # If unset, name of this script will be used.
#
# GG_PATH=<path of directory containing geogebra.jar> # If unset, path of this script will be used.
# In this case if the path of script does not contain the geogebra.jar file, /usr/share/geogebra will be used.
#
# GG_CONFIG_PATH=<path of directory containing .config/$GG_SCRIPTNAME/geogebra.conf> # If unset, $HOME will be used.
#
# JAVACMD=<Java command> # If unset, java will be used.
#
# GG_XMS=<initial Java heap size> # If unset, 32m will be used.
#
# GG_XMX=<maximum Java heap size> # If unset, 1024m will be used.
#
# GG_DJAVA_LIBRARY_PATH=<native library path>

GG_PATH='/usr/share/java/geogebra'

#---------------------------------------------
# If $GG_SCRIPTNAME not set, use name of this script.

if [ -z "$GG_SCRIPTNAME" ]; then
	GG_SCRIPTNAME="$(basename $0)"
fi

#---------------------------------------------
# If $GG_CONFIG_PATH not set, use $HOME.

if [ -z "$GG_CONFIG_PATH" ]; then
	GG_CONFIG_PATH="$HOME"
fi

#---------------------------------------------
# If $JAVACMD not set, use java.

if [ -z "$JAVACMD" ]; then
	JAVACMD='java'
fi

#---------------------------------------------
# If $GG_XMS not set, use 32m.

if [ -z "$GG_XMS" ]; then
	GG_XMS='32m'
fi

#---------------------------------------------
# If $GG_XMX not set, use 1024m.

if [ -z "$GG_XMX" ]; then
	GG_XMX='1024m'
fi

#---------------------------------------------
# Read default config file (if exists) and rewrite it.

GG_CONFIG_FILE="$GG_CONFIG_PATH/.config/$GG_SCRIPTNAME/geogebra.conf"
if [ ! -w "$GG_CONFIG_FILE" ]; then
	if [ ! -e "$GG_CONFIG_FILE" -a -w "$GG_CONFIG_PATH/.config/$GG_SCRIPTNAME" ]; then
		touch "$GG_CONFIG_FILE"
	elif [ ! -e "$GG_CONFIG_PATH/.config/$GG_SCRIPTNAME" -a -w "$GG_CONFIG_PATH/.config" ]; then
		mkdir "$GG_CONFIG_PATH/.config/$GG_SCRIPTNAME"
		touch "$GG_CONFIG_FILE"
	elif [ ! -e "$GG_CONFIG_PATH/.config" -a -w "$GG_CONFIG_PATH" ]; then
		mkdir "$GG_CONFIG_PATH/.config"
		mkdir "$GG_CONFIG_PATH/.config/$GG_SCRIPTNAME"
		touch "$GG_CONFIG_FILE"
	fi
fi
if [ -w "$GG_CONFIG_FILE" ]; then
	. "$GG_CONFIG_FILE"
	true > "$GG_CONFIG_FILE"
	cat > "$GG_CONFIG_FILE" << EOF
# This is the default GeoGebra configuration file. It shows what the defaults
# for various options happen to be.
#
# If you don't need to change the default, you shouldn't uncomment the line.
# Doing so may cause run-time problems.


# JAVA OPTIONS
# -----------------------------------------------------------------------------

# Set Java command, e.g. '/usr/bin/java'.
#
`if [ ! -n "$DEFAULT_JAVACMD" ]; then echo "# DEFAULT_JAVACMD='$JAVACMD'"; else echo "DEFAULT_JAVACMD='$DEFAULT_JAVACMD'"; fi`

# Set initial Java heap size, e.g. '32m'.
#
`if [ ! -n "$DEFAULT_GG_XMS" ]; then echo "# DEFAULT_GG_XMS='$GG_XMS'"; else echo "DEFAULT_GG_XMS='$DEFAULT_GG_XMS'"; fi`

# Set maximum Java heap size, e.g '1024m'.
#
`if [ ! -n "$DEFAULT_GG_XMX" ]; then echo "# DEFAULT_GG_XMX='$GG_XMX'"; else echo "DEFAULT_GG_XMX='$DEFAULT_GG_XMX'"; fi`

# Set native library path, e.g. '/usr/lib/jni'.
#
`if [ ! -n "$DEFAULT_GG_DJAVA_LIBRARY_PATH" -a -n "$GG_DJAVA_LIBRARY_PATH" ]; then echo "# DEFAULT_GG_DJAVA_LIBRARY_PATH='$GG_DJAVA_LIBRARY_PATH'"; elif [ ! -n "$DEFAULT_GG_DJAVA_LIBRARY_PATH" -a ! -n "$GG_DJAVA_LIBRARY_PATH" ]; then echo "# DEFAULT_GG_DJAVA_LIBRARY_PATH=''"; else echo "DEFAULT_GG_DJAVA_LIBRARY_PATH='$DEFAULT_GG_DJAVA_LIBRARY_PATH'"; fi`

EOF
fi

#---------------------------------------------
# Prefer default settings from config file.

if [ -n "$DEFAULT_JAVACMD" ]; then
	JAVACMD="$DEFAULT_JAVACMD"
fi
if [ -n "$DEFAULT_GG_XMS" ]; then
	GG_XMS="$DEFAULT_GG_XMS"
fi
if [ -n "$DEFAULT_GG_XMX" ]; then
	GG_XMX="$DEFAULT_GG_XMX"
fi
if [ -n "$DEFAULT_GG_DJAVA_LIBRARY_PATH" ]; then
	GG_DJAVA_LIBRARY_PATH="$DEFAULT_GG_DJAVA_LIBRARY_PATH"
fi

#---------------------------------------------
# Define usage function.

func_usage()
{
cat << _USAGE
Usage: $GG_SCRIPTNAME [Java-options] [GeoGebra-options] [FILE]

GeoGebra - Dynamic mathematics software

Java options:
  -JavaCMD=<command>                 Set Java command, default $JAVACMD
  -Xms<size>                         Set initial Java heap size, default $GG_XMS
  -Xmx<size>                         Set maximum Java heap size, default $GG_XMX
  -Djava.library.path=<path>         Set native library path`if [ -n "$GG_DJAVA_LIBRARY_PATH" ]; then echo ", default $GG_DJAVA_LIBRARY_PATH"; fi``if [ -w "$GG_CONFIG_FILE" ]; then  echo -e "\n\n  Edit $GG_CONFIG_FILE to change defaults."; fi`

GeoGebra options:
  --help                             Print this help message
  --v                                Print version
  --language=<iso_code>              Set language using locale code, e.g. en, de_AT
  --showAlgebraInput=<boolean>       Show/hide algebra input field
  --showAlgebraInputTop=<boolean>    Show algebra input field at top/bottom
  --showAlgebraWindow=<boolean>      Show/hide algebra window
  --showSpreadsheet=<boolean>        Show/hide spreadsheet
  --showCAS=<boolean>                Show/hide CAS window
  --showSplash=<boolean>             Enable/disable the splash screen
  --enableUndo=<boolean>             Enable/disable Undo
  --fontSize=<number>                Set default font size
  --showAxes=<boolean>               Show/hide coordinate axes
  --showGrid=<boolean>               Show/hide grid
  --settingsfile=[<path>|<filename>] Load/save settings from/in a local file
  --resetSettings                    Reset current settings
  --antiAliasing=<boolean>           Turn anti-aliasing on/off
  --regressionFile=<filename>        Export textual representations of dependent objects, then exit
_USAGE
}

#---------------------------------------------
# Check for option --help and pass Java options to Java, others to GeoGebra.

GG_OPTS=()
for i in "$@"; do
	case "$i" in
	--help | --hel | --he | --h )
		func_usage; exit 0 ;;
	esac
	if [ $(expr match "$i" '.*--') -ne 0 ]; then
		GG_OPTS[${#GG_OPTS[*]}]="$i"
		shift $((1))
	elif [ $(expr match "$i" '.*-Xms') -ne 0 ]; then
		GG_XMS=${i:4}
		shift $((1))
	elif [ $(expr match "$i" '.*-Xmx') -ne 0 ]; then
		GG_XMX=${i:4}
		shift $((1))
	elif [ $(expr match "$i" '.*-Djava.library.path') -ne 0 ]; then
		GG_DJAVA_LIBRARY_PATH=${i:20}
		shift $((1))
	elif [ $(expr match "$i" '.*-JavaCMD') -ne 0 ]; then
		JAVACMD=${i:9}
		shift $((1))
	fi
done
JAVA_OPTS=("-Xms$GG_XMS" "-Xmx$GG_XMX")
if [ -n "$GG_DJAVA_LIBRARY_PATH" ]; then
	JAVA_OPTS[${#JAVA_OPTS[*]}]="-Djava.library.path=$GG_DJAVA_LIBRARY_PATH"
fi

#---------------------------------------------
# Run

exec "$JAVACMD" "${JAVA_OPTS[@]}" -jar "$GG_PATH/geogebra-jogl2.jar" "${GG_OPTS[@]}" "$@"

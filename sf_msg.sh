#
# Copyright 2010 - Francois Laupretre <francois@tekwire.net>
#
#=============================================================================
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License (LGPL) as
# published by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#=============================================================================

#=============================================================================
# Section: Error handling
#=============================================================================

##----------------------------------------------------------------------------
# Displays an error message and aborts execution
#
# Args:
#	$1 : message
#	$2 : Optional. Exit code.
# Returns: Does not return. Exits with the provided exit code if arg 2 set,
#	with 1 if not.
# Displays: Error and abort messages
#-----------------------------------------------------------------------------

sf_fatal()
{
typeset rc

rc=1
[ -n "$2" ] && rc=$2

sf_error "$1"
echo
echo "******************* Abort *******************" >&2
exit $rc
}

##----------------------------------------------------------------------------
# Fatal error on unsupported feature
#
# Call this function when a feature is not available on the current
# operating system (yet ?)
#
# Args:
#	$1 : feature name
# Returns: Does not return. Exits with code 2.
# Displays: Error and abort messages
#-----------------------------------------------------------------------------

sf_unsupported()
{
# $1: feature name

sf_fatal "$1: Feature not supported in this environment" 2
}

##----------------------------------------------------------------------------
# Displays an error message
#
# If the ERRLOG environment variable is set, it is supposed to contain
# a path. The error message will be appnded to the file at this path. If
# the file does not exist, it will be created.
# Args:
#	$1 : Message
# Returns: Always 0
# Displays: Error message
#-----------------------------------------------------------------------------

sf_error()
{
typeset msg

msg="***ERROR: $1"
sf_msg "$msg"
[ -n "$ERRLOG" ] && echo "$msg" >>$ERRLOG
}

##----------------------------------------------------------------------------
# Displays a warning message
#
# Args:
#	$1 : message
# Returns: Always 0
# Displays: Warning message
#-----------------------------------------------------------------------------

sf_warning()
{
sf_msg " *===* WARNING *===* : $1"
}

#=============================================================================
# Section: User interaction
#=============================================================================

##----------------------------------------------------------------------------
# Displays a message (string)
#
# If the $sf_noexec environment variable is set, prefix the message with '(n)'
#
# Args:
#	$1 : message
# Returns: Always 0
# Displays: Message
#-----------------------------------------------------------------------------

sf_msg()
{
typeset prefix

prefix=''
[ -n "$sf_noexec" ] && prefix='(n)'
echo "$prefix$1"
}

##----------------------------------------------------------------------------
# Display trace message
#
# If the $sf_verbose environment variable is set, displays the message. If not,
# does not display anything.
#
# Args:
#	$1 : message
# Returns: Always 0
# Displays: message if verbose mode is active, nothing if not
#-----------------------------------------------------------------------------

sf_trace()
{
[ -n "$sf_verbose" ] && sf_msg1 ">>> $*"
}

##----------------------------------------------------------------------------
# Displays a message prefixed with spaces
#
# Args:
#	$1 : message
# Returns: Always 0
# Displays: message prefixed with spaces
#-----------------------------------------------------------------------------

sf_msg1()
{
sf_msg "        $*"
}

##----------------------------------------------------------------------------
# Displays a 'section' message
#
# This is a message prefixed with a linefeed and some hyphens. 
# To be used as paragraph/section title.
#
# Args:
#	$1 : message
# Returns: Always 0
# Displays: Message
#-----------------------------------------------------------------------------

sf_msg_section()
{
sf_msg ''
sf_msg "--- $1"
}

##----------------------------------------------------------------------------
# Displays a 'banner' message
#
# The message is displayed with an horizontal separator line above and below
#
# Args:
#	$1 : message
# Returns: Always 0
# Displays: message
#-----------------------------------------------------------------------------

sf_banner()
{
echo
echo "==================================================================="
echo " $1"
echo "==================================================================="
echo
}

##----------------------------------------------------------------------------
# Ask a question to the user
#
# Args:
#	$1 : Question
# Returns: Always 0
# Displays: message to stderr, answer to stdout
#-----------------------------------------------------------------------------

sf_ask()
{
echo "$SHELL" | grep bash >/dev/null
if [ $? = 0 ] ; then
	echo -n "$1 " >&2
else
	echo "$1 \c" >&2
fi

read answer
echo $answer
}

##----------------------------------------------------------------------------
# Asks a 'yes/no' question, gets answer, and return yes/no code
#
# Works at least for questions in english, french, and german :
# Accepts 'Y', 'O', and 'J' for 'yes' (upper or lowercase), and
# anything different is considered as 'no'
#- If the $sf_forceyes environment variable is set, the user is not asked
# and the 'yes' code is returned.
#
# Args:
#	$1 : Question string
# Returns: 0 for 'yes', 1 for 'no'
# Displays: Question and typed answer if $sf_forceyes not set, nothing if
#            $sf_forceyes is set.
#-----------------------------------------------------------------------------

sf_yn_question()
{
typeset answer

if [ -n "$sf_forceyes" ] ; then
	# sf_trace "Forcing answer to 'yes'"
	return 0
fi

answer=`sf_ask "$1"`

echo
[ "$answer" != o -a "$answer" != O \
	-a "$answer" != y -a "$answer" != Y \
	-a "$answer" != j -a "$answer" != J ] \
	&& return 1

return 0
}

#=============================================================================
##############################################################################
# Advanced mail handling à la spamgourmet
	
require ["copy"
	, "regex"
	, "variables"
	, "fileinto"
	, "mailbox"
	, "envelope"
        , "comparator-i;ascii-numeric"
        , "imap4flags"
        , "relational"
        , "subaddress" ];

set "spamjam_user"        "jr";
set "spamjam_counters"    "spamjam.counter";
set "spamjam_config"      "spamjam.config";
set "spamjam_mail"        "spamjam.mail";
set "spamjam_allow_all"   "x";
set "spamjam_junk_folder" "Junk";
set "spamjam_secret"   "lalala";

# set "yes"to enable secret matchword that has to be contained to enable folder creation
set "spamjam_secret_enabled"	"yes";

# Set to "yes" to accept the count from previoius unconfigured addresses, set to no to use
# spamjam_allow_default 
set "spamjam_allow_mailcount" "yes";

# default allowed count if spamjam_allow_mailcount is diabled
set "spamjam_allow_default" "2";


if envelope :user "to" "${spamjam_user}" {

  if envelope :regex :detail "to" "([x0-9])[.-]([a-z0-9]+)" {
    set :lower "spamcount" "${1}";
    set :lower "spamname" "${2}";
  } elsif envelope :regex :detail "to" "([a-z0-9]+)" {
    set :lower "spamname" "${1}";
    set "spamcount" "";
  } else {
    set "spamcount" "";
    set "spamname" "";
  }

        
  
if mailboxexists "${spamjam_config}.${spamname}.allow${spamjam_allow_all}" {
          set "allowedCount" "z";
	}
        elsif mailboxexists "${spamjam_config}.${spamname}.allow1" {
          set "allowedCount" "1";
        } 
        elsif mailboxexists "${spamjam_config}.${spamname}.allow2" {
          set "allowedCount" "2";
        }
        elsif mailboxexists "${spamjam_config}.${spamname}.allow3" {
          set "allowedCount" "3";
        }
        elsif mailboxexists "${spamjam_config}.${spamname}.allow4" {
          set "allowedCount" "4";
        }
        elsif mailboxexists "${spamjam_config}.${spamname}.allow5" {
          set "allowedCount" "5";
        }
        elsif mailboxexists "${spamjam_config}.${spamname}.allow6" {
          set "allowedCount" "6";
        }
        elsif mailboxexists "${spamjam_config}.${spamname}.allow7" {
          set "allowedCount" "7";
        }
        elsif mailboxexists "${spamjam_config}.${spamname}.allow8" {
          set "allowedCount" "8";
        }
        elsif mailboxexists "${spamjam_config}.${spamname}.allow9" {
          set "allowedCount" "9";
        }
else      # Else Create config mailbox if allowed
	{
	if string "${spamjam_secret_enabled}" "yes" { #has to have secret in order to create
		if not envelope :regex :detail "to" "(${spamjam_secret})"{
			fileinto :create "${spamjam_junk_folder}";
			stop;
		}
	}
	if string "${spamcount}" ""  {  #if no spamcount via mail set default, if in mail check if allowed else use default 
		set "allowedCount" "${spamjam_allow_default}";
	}     			
	else {
		if string "${spamjam_allow_mailcount}" "yes"{
			set "allowedCount" "${spamcount}";# take from mail
			}
		else { 
		set "allowedCount" "${spamjam_allow_default}"; #set default if not alloed from mail
		}
	}		
fileinto :flags "\\Deleted" :create "${spamjam_config}.${spamname}.allow${allowedcount}";
}
  


    # Find the number of mails we received for that address, including the
    # current message.
    if mailboxexists "${spamjam_counters}.${spamname}.9" {
      set "currentCount" "10";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.8" {
      set "currentCount" "9";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.7" {
      set "currentCount" "8";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.6" {
      set "currentCount" "7";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.5" {
      set "currentCount" "6";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.4" {
      set "currentCount" "5";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.3" {
      set "currentCount" "4";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.2" {
      set "currentCount" "3";
    }
    elsif mailboxexists "${spamjam_counters}.${spamname}.1" {
      set "currentCount" "2";
    } else {
      set "currentCount" "1";
    }
  # check if allow all or current count low enough and inc counter
    if string "${allowedCount}" "z"{
      fileinto :flags "\\Deleted" :create "${spamjam_counters}.${spamname}.${currentCount}";
      fileinto :create "${spamjam_mail}";
          stop;
  }
    elsif string :value "le" :comparator "i;ascii-numeric" "${currentCount}" "${allowedCount}" {
      fileinto :flags "\\Deleted" :create "${spamjam_counters}.${spamname}.${currentCount}";
      fileinto :create "${spamjam_mail}";# alles nur in einen folder.${spamname}";
      stop;
    }
 
    fileinto :create "${spamjam_junk_folder}";
    stop;
}

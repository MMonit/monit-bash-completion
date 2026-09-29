# monit(1) completion

# Search words for the control file specified with -c/--conf.
# @var[out] REPLY  Control file, or empty if not specified
_comp_cmd_monit__conffile()
{
    REPLY=""
    local noargopts='!(-*|*[cdglps]*)'
    local i word=""
    for ((i = 1; i < cword; i++)); do
        # shellcheck disable=SC2254
        case ${words[i]} in
            --conf | -${noargopts}c)
                ((++i < cword)) && word=${words[i]}
                ;;
            --conf=*)
                word=${words[i]#*=}
                ;;
            -${noargopts}c*)
                word=${words[i]#*c}
                ;;
        esac
    done
    [[ $word ]] && _comp_dequote "$word"
}

# Generate the commands listed in the help output.
# @param $1  Command
_comp_cmd_monit__compgen_commands()
{
    _comp_compgen_split -- "$("$1" -h 2>/dev/null | _comp_awk '
        /^Optional commands/ { commands = 1; next }
        commands && /^ [a-z]/ && !seen[$1]++ { print $1 }')"
}

# Generate the names of the services defined in the control file.
# @param $1  Command
# @param $2  Control file, if other than the default one
_comp_cmd_monit__compgen_services()
{
    _comp_compgen_split -l -- "$("$1" ${2:+-c "$2"} -vIt 2>/dev/null |
        command sed -ne 's/^[A-Z][A-Za-z ]* Name  *= //p')"
}

# Generate the names of the service groups defined in the control file.
# @param $1  Command
# @param $2  Control file, if other than the default one
_comp_cmd_monit__compgen_groups()
{
    _comp_compgen_split -l -- "$("$1" ${2:+-c "$2"} -vIt 2>/dev/null |
        _comp_awk '
            sub(/^ Group +=  */, "") { gsub(/, /, "\n"); print }')"
}

_comp_cmd_monit()
{
    local cur prev words cword was_split comp_args
    _comp_initialize -s -- "$@" || return

    local REPLY conffile
    _comp_cmd_monit__conffile
    conffile=$REPLY

    # Options are recognized before the command only, what follows the command
    # are its arguments.
    local noargopts='!(-*|*[cdglps]*)'
    local optarg_opts="--conf|--daemon|--group|--logfile|--pidfile|--statefile"
    optarg_opts="@($optarg_opts|-${noargopts}[cdglps])"
    if _comp_locate_first_arg -a "$optarg_opts"; then
        ((cword == REPLY + 1)) || return
        case ${words[REPLY]} in
            start | stop | restart | monitor | unmonitor)
                _comp_compgen -i monit services "$1" "$conffile"
                _comp_compgen -a -- -W 'all'
                ;;
            status | summary)
                _comp_compgen -i monit services "$1" "$conffile"
                ;;
            report)
                _comp_compgen -- -W 'up down initialising unmonitored total'
                ;;
            procmatch)
                _comp_compgen_pnames
                ;;
        esac
        return
    fi

    # shellcheck disable=SC2254
    case $prev in
        --help | --version | --daemon | -${noargopts}[hVd])
            return
            ;;
        --conf | --pidfile | --statefile | --hash | -${noargopts}[cpsH])
            _comp_compgen_filedir
            return
            ;;
        --logfile | -${noargopts}l)
            _comp_compgen_filedir
            _comp_compgen -a -- -W 'syslog'
            return
            ;;
        --group | -${noargopts}g)
            _comp_compgen -i monit groups "$1" "$conffile"
            return
            ;;
    esac

    [[ $was_split ]] && return

    if [[ $cur == -* ]]; then
        # Long options are hardcoded, the help output lists the short ones only
        _comp_compgen -- -W '--batch --conf --daemon --group --hash --help
            --id --interactive --logfile --pidfile --resetid --statefile
            --test --verbose --version'
        return
    fi

    _comp_compgen -i monit commands "$1"
} &&
    complete -F _comp_cmd_monit monit

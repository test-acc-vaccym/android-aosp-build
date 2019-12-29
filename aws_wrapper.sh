#!/bin/bash

# commands to wrap with local
# aws s3 ls
# aws s3 cp
# aws s3 sync

DBUG="true"
_awl() {
  [ $DBUG = "true" ] && echo -e "\e[2m$(date "+%Y-%m-%d %H:%M:%S"): $@\e[22m" >/dev/tty 
}
aws(){
    ALL_ARGS=("$@")
    AWS_ENV_TYPE=$1
    AWS_CMD=$2
    REST_OF_ARGS="${ALL_ARGS[@]:2}"
    AWS_S3_DESCR="s3://"
    MOD_ARGS=${REST_OF_ARGS//$AWS_S3_DESCR/"$HOME/"}
    if [[ "$AWS_ENV_TYPE" = "s3" ]]; then
        case "$AWS_CMD" in 
            ls)
                if [ -f ${MOD_ARGS} ] || [ -d ${MOD_ARGS} ]; then
                    _awl "aws cmd replacement: aws $@ <-to-> ls ${MOD_ARGS}"
                    ls ${MOD_ARGS}
                else
                    _awl "aws cmd replacement: aws $@ <-to-> printf \"\""
                    printf ""
                fi
            ;;
            cp)
                if [[ "${ALL_ARGS[2]}" = "-" ]]; then # ${ALL_ARGS[2]} src is - do something
                    _awl "aws cmd replacement: aws $@ <-to-> cat 1>${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"}"
                    cat 1>${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"}
                elif [[ "${ALL_ARGS[3]}" = "-" ]]; then # ${ALL_ARGS[3]} dst is - do something
                    if [ -f ${ALL_ARGS[2]//$AWS_S3_DESCR/"$HOME/"} ]; then
                        _awl "aws cmd replacement: aws $@ <-to-> cat ${ALL_ARGS[2]//$AWS_S3_DESCR/"$HOME/"}"
                        cat ${ALL_ARGS[2]//$AWS_S3_DESCR/"$HOME/"}
                    else
                        _awl "aws cmd replacement: aws $@ <-to-> printf \"\""
                        printf ""
                    fi
                else #else just a normal copy
                    _awl "aws cmd replacement: aws $@ <-to-> cp ${MOD_ARGS}"
                    cp ${MOD_ARGS} 
                fi
            ;;
            sync)
                _awl "aws cmd replacement: aws $@ <-to-> rsync ${MOD_ARGS}"
                rsync ${MOD_ARGS}
            ;;
            rm)
                _awl "aws cmd replacement: aws $@ <-to-> rm ${MOD_ARGS}"
                rm ${MOD_ARGS}
            ;;
            mkdir)
                _awl "aws cmd replacement: aws $@ <-to-> mkdir ${MOD_ARGS}"
                mkdir ${MOD_ARGS}
            ;;
            *)
            _awl "command $AWS_CMD not recognized. review and update script. stopping..."
            exit 1
            ;;
        esac
    fi
    if [[ "$AWS_ENV_TYPE" = "sns" ]]; then
        _awl "ATTENTION no SNS available yet: $@"
        # read -p "Press enter to continue"
    fi
}

[[ $# -ne 0 ]] && aws $@

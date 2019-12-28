#!/bin/bash

# commands to wrap with local
# aws s3 ls
# aws s3 cp
# aws s3 sync
llog() {
  echo "$(date "+%Y-%m-%d %H:%M:%S"): $1"
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
                llog "aws cmd replacement: aws $@ <-to-> ls ${MOD_ARGS}"
                ls ${MOD_ARGS}
            ;;
            cp)
                if [[ "${ALL_ARGS[2]}" = "-" ]]; then # ${ALL_ARGS[2]} src is - do something
                    llog "aws cmd replacement: aws $@ <-to-> cat 1>${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"}"
                    [ ! -d ${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"} ] && mkdir -p "$(dirname ${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"})"
                    [ ! -f ${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"} ] && touch "${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"}"
                    cat 1>${ALL_ARGS[3]//$AWS_S3_DESCR/"$HOME/"}
                elif [[ "${ALL_ARGS[3]}" = "-" ]]; then # ${ALL_ARGS[3]} dst is - do something
                    llog "aws cmd replacement: aws $@ <-to-> cat ${ALL_ARGS[2]//$AWS_S3_DESCR/"$HOME/"}"
                    [ -f ${ALL_ARGS[2]//$AWS_S3_DESCR/"$HOME/"} ] && cat ${ALL_ARGS[2]//$AWS_S3_DESCR/"$HOME/"} || echo ""
                else #else just a normal copy
                    llog "aws cmd replacement: aws $@ <-to-> cp ${MOD_ARGS}"
                    cp ${MOD_ARGS} 
                fi
            ;;
            sync)
                llog "aws cmd replacement: aws $@ <-to-> rsync ${MOD_ARGS}"
                rsync ${MOD_ARGS}
            ;;
            *)
            llog "command $AWS_CMD not recognized. review and update script. stopping..."
            exit 1
            ;;
        esac
    fi
    if [[ "$AWS_ENV_TYPE" = "sns" ]]; then
        llog "ATTENTION no SNS available yet: $@"
        read -p "Press enter to continue"
    fi
}

[[ $# -ne 0 ]] && aws $@

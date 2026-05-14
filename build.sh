#!/bin/bash
set -euo pipefail

BASE=$(pwd)

GS=$(ls -d *game 2>/dev/null | head -n 1)
NET=$(ls -d *net 2>/dev/null | head -n 1)
SKILL=$(ls -d *skill 2>/dev/null | head -n 1)

GS=${GS:-cgame}
NET=${NET:-cnet}
SKILL=${SKILL:-cskill}

echo ""
echo "=========================== setup $NET ==========================="
echo ""
cd "$BASE/$NET"
rm -f common io mk storage rpc lua rpcgen
ln -sf ~/share/common/ .
ln -sf ~/share/io/ .
ln -sf ~/share/mk/ .
ln -sf ~/share/storage/ .
ln -sf ~/share/rpc/ .
ln -sf ~/share/lua/ .
ln -sf ~/share/rpcgen .
chmod +x ~/share/rpcgen
chmod +x ~/share/rpc/*
echo ""
echo "=========================== setup iolib ==========================="
echo ""
cd "$BASE"
mkdir -p iolib/inc
cd "$BASE/iolib/inc"
rm -f *
ln -sf "../../$NET/gamed/auctionsyslib.h" .
ln -sf "../../$NET/gamed/sysauctionlib.h" .
ln -sf "../../$NET/gdbclient/db_if.h" .
ln -sf "../../$NET/gamed/factionlib.h" .
ln -sf "../../$NET/common/glog.h" .
ln -sf "../../$NET/gamed/gsp_if.h" .
ln -sf "../../$NET/gamed/mailsyslib.h" .
ln -sf "../../$NET/gamed/privilege.hxx" .
ln -sf "../../$NET/gamed/sellpointlib.h" .
ln -sf "../../$NET/gamed/stocklib.h" .
ln -sf "../../$NET/gamed/webtradesyslib.h" .
ln -sf "../../$NET/gamed/kingelectionsyslib.h" .
ln -sf "../../$NET/gamed/pshopsyslib.h" .
ln -sf "../../$NET/gdbclient/db_os.h" .
ln -sf /root/share/io/luabase.h .

cd "$BASE/iolib"
rm -f lib*
ln -sf "../$NET/io/libgsio.a" .
ln -sf "../$NET/gdbclient/libdbCli.a" .
ln -sf "../$SKILL/skill/libskill.a" .
ln -sf "../$NET/gamed/libgsPro2.a" .
ln -sf "../$NET/logclient/liblogCli.a" .

echo ""
echo "======================== modify Rules.make ========================"
echo ""
EPWD=$(echo "$BASE" | sed -e 's/\//\\\//g')
cd "$BASE/$GS"
sed -i -e "s/IOPATH=.*$/IOPATH=$EPWD\/iolib/g" \
       -e "s/BASEPATH=.*$/BASEPATH=$EPWD\/$GS/g" Rules.make

echo ""
echo "====================== softlink libskill.so ======================="
echo ""
cd "$BASE/$GS/gs"
rm -f libskill.so
ln -sf "../../$SKILL/libskill.so" .

cd "$BASE"

# ---------------------------------------------------------------------------

buildrpcgen()
{
    echo ""
    echo "========================== $NET rpcgen ============================"
    echo ""
    cd "$BASE/$NET"
    ./rpcgen rpcalls.xml
    cd "$BASE"
}

buildrpcdata()
{
    echo ""
    echo "========================== $NET CP rpcdata ============================"
    echo ""
    #cp ./add/ec_sqlarenateammember "$BASE/$NET/rpcdata/ec_sqlarenateammember"
    #cp ./add/ec_sqlarenateam "$BASE/$NET/rpcdata/ec_sqlarenateam"
}

installfunc()
{
    echo ""
    echo "======================= Instalando as deamons ========================="
    echo ""
    cp "$BASE/$GS/gs/gs"              /home/gamed/gs
    cp "$BASE/$GS/gs/libtask.so"      /home/gamed/libtask.so
    cp "$BASE/$SKILL/libskill.so"     /home/gamed/libskill.so
    cp "$BASE/$NET/gfaction/gfactiond"    /home/gfactiond/gfactiond
    cp "$BASE/$NET/gauthd/gauthd"         /home/gauthd/gauthd
    cp "$BASE/$NET/uniquenamed/uniquenamed" /home/uniquenamed/uniquenamed
    cp "$BASE/$NET/gamedbd/gamedbd"       /home/gamedbd/gamedbd
    cp "$BASE/$NET/gdeliveryd/gdeliveryd" /home/gdeliveryd/gdeliveryd
    cp "$BASE/$NET/glinkd/glinkd"         /home/glinkd/glinkd
    cp "$BASE/$NET/gacd/gacd"             /home/gacd/gacd
    cp "$BASE/$NET/logservice/logservice" /home/logservice/logservice
    echo ""
    echo "============================== Sucesso!! ==============================="
    echo ""
}

installprotectfunc()
{
    echo ""
    echo "======================= Movendo ========================="
    echo ""
    cp "$BASE/$GS/gs/gs"                   /root/get_protects/gs
    cp "$BASE/$NET/gfaction/gfactiond"     /root/get_protects/gfactiond
    cp "$BASE/$NET/gauthd/gauthd"          /root/get_protects/gauthd
    cp "$BASE/$NET/uniquenamed/uniquenamed" /root/get_protects/uniquenamed
    cp "$BASE/$NET/gamedbd/gamedbd"        /root/get_protects/gamedbd
    cp "$BASE/$NET/gdeliveryd/gdeliveryd"  /root/get_protects/gdeliveryd
    cp "$BASE/$NET/glinkd/glinkd"          /root/get_protects/glinkd
    echo ""
    echo "====================== Sucesso =========================="
    echo ""
}

buildgslib()
{
    echo ""
    echo "======================= build liblogCli.a ========================="
    echo ""
    cd "$BASE/$NET/logclient"
    make clean
    make -f Makefile.gs clean
    make -f Makefile.gs -j32

    echo ""
    echo "======================== build libgsPro2.a ========================="
    echo ""
    cd "$BASE/$NET/gamed"
    make clean
    make lib -j32

    echo ""
    echo "======================== build libdbCli.a =========================="
    echo ""
    cd "$BASE/$NET/gdbclient"
    make clean
    make lib -j32

    echo ""
    echo "============================ make libgs ============================"
    echo ""
    cd "$BASE/$GS/libgs"
    mkdir -p io gs db sk log
    make

    cd "$BASE"
}

buildskill()
{
    echo ""
    echo "============================= ant gen =============================="
    echo ""
    cd "$BASE/$SKILL/skill/gen"
    mkdir -p skills buffcondition
    ant

    echo ""
    echo "========================== gen skills =============================="
    echo ""
    chmod a+x gen
#   ./gen

    echo ""
    echo "======================= build libskill.o ========================="
    echo ""
    make clean
    make -j32

    cd "$BASE"
}

buildgame()
{
    echo ""
    echo "======================= build $GS ========================="
    echo ""
    cd "$BASE/$GS"
    make clean
    make -j32
    cd "$BASE"
}

buildtask()
{
    echo ""
    echo "======================= build libtask.o ========================="
    echo ""
    cd "$BASE/$GS/gs/task"
    make clean
    make lib -j32
    cd "$BASE"
}

builddeliver()
{
    cd "$BASE/$NET"

    #echo ""
    #echo "========================== build licenseclient =============================="
    #echo ""
    #cd licenseclient
    #make clean
    #make -j32
    #make lib
    #cd ..

    echo ""
    echo "========================== build gauthd =============================="
    echo ""
    cd gauthd
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build logservice =============================="
    echo ""
    cd logservice
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build gacd =============================="
    echo ""
    cd gacd
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build glinkd =============================="
    echo ""
    cd glinkd
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build gdeliveryd =============================="
    echo ""
    cd gdeliveryd
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build gamedbd =============================="
    echo ""
    cd gamedbd
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build uniquenamed =============================="
    echo ""
    cd uniquenamed
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build libgsio =============================="
    echo ""
    cd io
    make lib -j32
    cd ..

    echo ""
    echo "========================== build gfaction =============================="
    echo ""
    cd gfaction
    make clean
    make -j32
    cd ..

    cd "$BASE"
}

builddeliveryd()
{
    cd "$BASE/$NET"

    echo ""
    echo "========================== build gdeliveryd =============================="
    echo ""
    cd gdeliveryd
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build gamedbd =============================="
    echo ""
    cd gamedbd
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build uniquenamed =============================="
    echo ""
    cd uniquenamed
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build libgsio =============================="
    echo ""
    cd io
    make lib -j32
    cd ..

    echo ""
    echo "========================== build gfaction =============================="
    echo ""
    cd gfaction
    make clean
    make -j32
    cd ..

    echo ""
    echo "========================== build gacd =============================="
    echo ""
    cd gacd
    make clean
    make -j32
    cd ..

    cd "$BASE"
}

buildgs()
{
    echo ""
    echo "========================== build gs =============================="
    echo ""
    cd "$BASE/$GS/gs"
    make clean
    make -j32
    cd "$BASE"
}

rebuilddeliver()
{
    buildrpcgen
    #buildrpcdata
    builddeliver
}

rebuilddeliver2()
{
    builddeliver
}

rebuildgs()
{
    #buildrpcdata
    buildgslib
}

rebuildall()
{
    echo ""
    echo "========================== build game all =============================="
    echo ""
    buildrpcgen
    buildrpcdata
    builddeliver
    buildgslib
    buildskill
    buildgame
    installfunc
    installprotectfunc
}

install()
{
    echo ""
    echo "========================== Instalando.... =============================="
    echo ""
    installfunc
    installprotectfunc
}

if [ $# -gt 0 ]; then
    case "$1" in
        deliver)   rebuilddeliver ;;
        gs)        rebuildgs ;;
        all)       rebuildall ;;
        install)   install ;;
        deliveryd) rebuilddeliver2 ;;
        *)
            echo "Unknown command: $1"
            echo "Usage: $0 [deliver|gs|all|install|deliveryd]"
            exit 1
            ;;
    esac
fi

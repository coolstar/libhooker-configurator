//
//  mountData.c
//  libhooker configurator
//
//  Created by CoolStar on 1/26/21.
//  Copyright © 2021 coolstar. All rights reserved.
//

#include "mountData.h"
#include <stdio.h>
#include <sys/mount.h>

bool isUnionMountPresent(void){
    struct statfs *mntbuf;
    int mntsize;
    if ((mntsize = getmntinfo(&mntbuf, MNT_NOWAIT)) == 0){
        printf("Unable to get mounts\n");
        return false;
    }
    for (int i = 0; i < mntsize; i++){
        if ((mntbuf[i].f_flags & MNT_UNION) == MNT_UNION){
            return true;
        }
    }
    return false;
}

//
//  SYTransMp3Tool.m
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/7/8.
//  Copyright © 2019 bsy. All rights reserved.
//

#import "SYTransMp3Tool.h"
#import "lame.h"
@implementation SYTransMp3Tool

- (BOOL) convertMp3from:(NSString *)wavpath topath:(NSString *)mp3path
{
    NSString *filePath =wavpath ;

    NSString *mp3FilePath = mp3path;

    BOOL isSuccess = NO;
    if (filePath == nil  || mp3FilePath == nil){
        return isSuccess;
    }

    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除");
    }

    @try {
        int read, write;

        FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        if (pcm) {
            fseek(pcm, 4*1024, SEEK_CUR);
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];

            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 4000.0);
            lame_set_num_channels(lame, 1);//通道
            lame_set_quality(lame, 1);//质量
            lame_set_VBR(lame, vbr_default);
            lame_set_brate(lame, 16);
            lame_set_mode(lame, 3);
            lame_init_params(lame);

            do {
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

                fwrite(mp3_buffer, write, 1, mp3);

            } while (read != 0);

            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
            isSuccess = YES;
        }
        //skip file header
    }
    @catch (NSException *exception) {
        NSLog(@"error");
    }
    @finally {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        return isSuccess;
    }

}
@end

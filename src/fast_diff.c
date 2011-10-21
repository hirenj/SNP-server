#include<stdio.h>
#include<stdlib.h>
#include<string.h>

//Max protein length 5336
//cat TAIR9-Agu-json.txt | awk -F'","' '{ print $1 "," $3 }' | sed -e 's/"]}//' | sed -e 's/^.*"//' > ../modfinder/analysis/agu_seqs.txt

void calculate_diffs(char *refs, char *accs) {
    FILE *ref_ptr = fopen(refs, "r+");
    FILE *acc_ptr = fopen(accs, "r+");

    char ref_line[6000];
    char acc_line[6000];
    
    while ( fgets( ref_line, sizeof ref_line, ref_ptr) != NULL )
    {
        fgets( acc_line, sizeof acc_line, acc_ptr );
        char *ref_agi = strtok(ref_line, ",");
        char *ref_seq = strtok(NULL,",");
        char *acc_agi = strtok(acc_line, ",");
        char *acc_seq = strtok(NULL,",");

        while (strcmp(ref_agi,acc_agi) != 0) {
//            printf("Missing %s %s\n",ref_agi,acc_agi);
            if (fgets( ref_line, sizeof ref_line, ref_ptr) == NULL) {
                exit(0);
            }
            ref_agi = strtok(ref_line, ",");
            ref_seq = strtok(NULL,",");            
            continue;
        }

        if (ref_seq == NULL || acc_seq == NULL) {
            break;
        }

        ref_seq[strlen(ref_seq) - 1] = '\0';
        acc_seq[strlen(acc_seq) - 1] = '\0';

        printf("%s ",ref_agi);
        
        int position = 0;
        int ref_length = strlen(ref_seq);

        while (position < ref_length) {
            while( acc_seq[0] == ref_seq[0] && acc_seq[0] != '\0' && ref_seq[0] != '\0') {
                acc_seq++;
                ref_seq++;
                position++;
            }
        
            if (acc_seq[0] == '\0' && ref_seq[0] != '\0') {
                while (ref_seq[0] != '\0') {
                    printf("%d:%c-,",position,ref_seq[0]);
                    ref_seq++;
                    position++;
                }
                break;
            }

            if (ref_seq[0] == '\0' && acc_seq[0] != '\0') {
                while (acc_seq[0] != '\0') {
                    printf("%d:+%c,",position,acc_seq[0]);
                    acc_seq++;
                    position++;
                }
                break;
            }
        
            if (ref_seq[0] == '\0' && acc_seq[0] == '\0') {
                break;
            }
        
            printf("%d:%c%c,",position,ref_seq[0],acc_seq[0]);
            position++;
            ref_seq++;
            acc_seq++;
        }
        printf("\n");
    }

    fclose(ref_ptr);
    fclose(acc_ptr);
    return;
}

int main(int argc, char *argv[])
{
    calculate_diffs(argv[1],argv[2]);
    return 0;
}

#!/usr/bin/env python
from subprocess import check_output
import sys
import os


def base36encode(number, alphabet='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'):
    """Converts an integer to a base36 string."""
    if not isinstance(number, (int, long)):
        raise TypeError('number must be an integer')

    base36 = ''
    sign = ''

    if number < 0:
        sign = '-'
        number = -number

    if 0 <= number < len(alphabet):
        return sign + alphabet[number]

    while number != 0:
        number, i = divmod(number, len(alphabet))
        base36 = alphabet[i] + base36

    return sign + base36


def qsub(i):
    args = [
        'qsub',
        '-q', 'all.q',  # general.q@worker?
        '-w', 'e',  # Abort on error
        '-A', 'vagrant',
        '-N', 'job_' + base36encode(i),
        '-V',  # Pass all environment
        '-v', 'EXAMPLE_ENV=1',  # Pass specific environment
        '-l', 'h_rt=00:06:00', # hard runtime limit hh:mm:ss
        # '-P', 'ProjectA',  # I haven't configured (qconf'd) this properly yet?
        # '-pe', 'smp', '1', # shared memory with 1 slot
        '-wd', os.getcwd(),  # Set working directory    
        # Run sleep for 300 seconds
        '-b', 'n',
        '/vagrant/bin/thing_doer'  # 'sleep', '300'
    ]

    print(check_output(args))


if __name__ == '__main__':
    os.environ['SGE_ROOT'] = '/opt/sge'
    os.environ['PATH'] = ':'.join([os.environ['PATH'], '/opt/sge/bin/lx-amd64'])
    num_jobs = 100
    if len(sys.argv) == 2:
        num_jobs = int(sys.argv[1])
    
    map(qsub, range(num_jobs))
    print(check_output('qstat'))


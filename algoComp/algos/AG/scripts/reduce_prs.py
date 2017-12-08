import os
import argparse

def reduce(list_files, n):
	"""Discard the n first parses of each files, parses are separated by 1 empty line"""
	for fid in list_files:
		# print "processing " + fid
		counter = 0
		(prefix, suffix) = os.path.splitext(fid)
		line = 'initial'
		outfile = prefix + '-last' + suffix
		with open(fid) as f:
			while counter <= n and line:
				line = f.readline()
				if line == '\n':
					counter += 1
			with open(outfile, 'w') as out:
				while line:
					line = f.readline()
					out.write(line)
	return


parser = argparse.ArgumentParser(prog='PROG')
parser.add_argument('list_files', nargs='+')
parser.add_argument('-n', '--n_iter', required=True)
args = parser.parse_args()
reduce(args.list_files, int(args.n_iter))

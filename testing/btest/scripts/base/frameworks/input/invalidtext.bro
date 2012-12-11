# @TEST-EXEC: btest-bg-run bro bro -b --pseudo-realtime -r $TRACES/socks.trace %INPUT
# @TEST-EXEC: btest-bg-wait -k 5
# @TEST-EXEC: btest-diff out
# @TEST-EXEC: sed 1d .stderr > .stderrwithoutfirstline
# @TEST-EXEC: TEST_DIFF_CANONIFIER="$SCRIPTS/diff-remove-abspath | $SCRIPTS/diff-remove-timestamps" btest-diff .stderrwithoutfirstline

@TEST-START-FILE input.log
#separator \x09
#fields	i	c
#types	int	count
	l
	5
@TEST-END-FILE

global outfile: file;

module A;

type Idx: record {
	i: string;
};

type Val: record {
	c: count;
};

global servers: table[string] of Val = table();

event bro_init()
	{
	outfile = open("../out");
	# first read in the old stuff into the table...
	Input::add_table([$source="../input.log", $name="ssh", $idx=Idx, $val=Val, $destination=servers]);
	Input::remove("ssh");
	}

event Input::end_of_data(name: string, source:string)
	{
	print outfile, servers;
	terminate();
	}

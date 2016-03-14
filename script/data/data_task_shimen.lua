--<<data_task_shimen 导表开始>>
data_task_shimen = {

	[30001] = {
		taskid = 30001,
		name = "与人对话",
		category = "师门",
		type = 5,
		param = {npcid=20000001,talkid=10001},
		award = {{type=1,value={[1]=100,[2]=200}},},
		help_award = {},
		openlv = 30,
		pretask = {},
		nexttask = {[3020002]=1,[3010003]=1,[3040004]=1},
		autoaccept = 1,
		autosubmit = 1,
		cangiveup = 1,
		finishbyclient = 0,
		desc = [[]],
		award_desc = [[]],
		help_award_desc = [[]],
	},

	[30002] = {
		taskid = 30002,
		name = "巡逻遇怪",
		category = "师门",
		type = 2,
		param = {locid=10001,warid=10001},
		award = {{type=1,value={[1]=100,[2]=200}},},
		help_award = {},
		openlv = 30,
		pretask = {},
		nexttask = {[3020001]=1,[3010003]=1,[3040004]=1},
		autoaccept = 1,
		autosubmit = 1,
		cangiveup = 1,
		finishbyclient = 0,
		desc = [[]],
		award_desc = [[]],
		help_award_desc = [[]],
	},

	[30003] = {
		taskid = 30003,
		name = "给予物品",
		category = "师门",
		type = 1,
		param = {npcid=10001,type=10000001,num=1},
		award = {{type=1,value={[1]=100,[2]=200}},},
		help_award = {},
		openlv = 30,
		pretask = {},
		nexttask = {[3020002]=1,[3010001]=1,[3040004]=1},
		autoaccept = 1,
		autosubmit = 1,
		cangiveup = 1,
		finishbyclient = 0,
		desc = [[]],
		award_desc = [[]],
		help_award_desc = [[]],
	},

	[30004] = {
		taskid = 30004,
		name = "给予宠物",
		category = "师门",
		type = 4,
		param = {npcid=10002,type=101,num=1},
		award = {{type=1,value={[1]=100,[2]=200}},},
		help_award = {},
		openlv = 30,
		pretask = {},
		nexttask = {[3020002]=1,[3010003]=1,[3040001]=1},
		autoaccept = 1,
		autosubmit = 1,
		cangiveup = 1,
		finishbyclient = 0,
		desc = [[]],
		award_desc = [[]],
		help_award_desc = [[]],
	},

}
return data_task_shimen
--<<data_task_shimen 导表结束>>

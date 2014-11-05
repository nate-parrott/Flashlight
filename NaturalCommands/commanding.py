from collections import defaultdict
import math
import re

class ProbabilityCounter(object):
	def __init__(self):
		self.counts = defaultdict(int)
		self.total = 0
	
	def add(self, item):
		self.counts[item] += 1
		self.total += 1
	
	def __getitem__(self, item):
		return self.counts[item] * 1.0 / self.total if item in self.counts else 0.0

	def iteritems(self):
		return ((item, count * 1.0 / self.total) for (item, count) in self.counts.iteritems())

SMOOTHING = 0.000001
FREE_TEXT_PROB = 0.0001

def smooth_log_prob(p):
	return math.log((p+SMOOTHING) * (1 - SMOOTHING))

class Phrase(object):
	def __init__(self, intent, items):
		self.intent = intent
		self.items = items

	def items_with_intermediate_states(self):
		items = []
		prev_item_name = "$START_{0}".format(self.intent)
		for item, i in zip(self.items, xrange(len(self.items))):
			if isinstance(item, list):
				name = item[0]
				prev_item_name = name
				items.append(item)
			elif isinstance(item, str) or isinstance(item, unicode):
				next_item_name = self.items[i+1][0] if i+1 < len(self.items) else "$END_{0}".format(self.intent)
				intermediate_item_name = "[{0}:{1}..{2}]".format(self.intent, prev_item_name, next_item_name)
				items.append([intermediate_item_name, item])
		return items

	def token_state_tuples(self):
		tuples = []
		for item in self.items_with_intermediate_states():
			for token in tokenize(item[1]):
				tuples.append((token, item[0]))
		return tuples

	def __repr__(self):
		return "[{0}: {1}]".format(self.intent, self.items)

	def get(self, key, default):
		for item in self.items:
			if isinstance(item, list) and item[0] == key:
				return item[1]
		return default
	
	def tags(self):
		d = {}
		for item in self.items:
			if isinstance(item, list):
				d[item[0]] = item[1]
		return d

def flatten(list_of_lists):
	return reduce(lambda a, b: a+b, list_of_lists, [])

def split_strings_by_regex(strings, regex):
	print regex, type(regex), strings
	return flatten(map(lambda s: re.split(regex, s), strings))

def tokenize(text, preserve_regexes=None):
	text = text.lower()
	tokens = re.split(r"\s+", text)
	return tokens

def count_runs(items):
	runs = []
	for item in items:
		if len(runs) > 0 and runs[-1][0] == item:
			runs[-1] = (item, runs[-1][1]+1)
		else:
			runs.append((item, 1))
	return runs

def phrase_from_candidate(candidate, tokens):
	log_prob, intent, states = candidate
	states = states[1:] # strip '$START'
	items = []
	for state, n_tokens in count_runs(states):
		if state[0] == '[':
			# it's an intermediate state, so don't preserve it in output:
			items.append(" ".join(tokens[:n_tokens]))
		else:
			items.append([state, " ".join(tokens[:n_tokens])])
		tokens = tokens[n_tokens:]
	return Phrase(intent, items)

def parse_phrase(text, examples, state_regexes=None):
	if state_regexes == None: state_regexes = {}
	transition_probs = defaultdict(ProbabilityCounter)
	emission_probs = defaultdict(ProbabilityCounter)
	intents = set()
	states_for_root_states = defaultdict(set)
	for ex in examples:
		intents.add(ex.intent)
		# count transitions:
		states = map(lambda (token, state): state, ex.token_state_tuples())
		for state, next_state in zip(['$START_{0}'.format(ex.intent)] + states, states + ['$END_{0}'.format(ex.intent)]):
			transition_probs[state.split('/')[0]].add(next_state.split('/')[0])
			states_for_root_states[state.split('/')[0]].add(state)
		# count emissions:
		for item in ex.items_with_intermediate_states():
			name = item[0]
			if name[0] != '~':
				for token in tokenize(item[1]):
					emission_probs[name].add(token)
	def get_emission_prob(state, token):
		if state[0] == '~':
			return FREE_TEXT_PROB
		elif state[0] == '*':
			# a regex state:
			# print "does {0} match {1}? {2}".format(token, state[1:], re.match(state_regexes[state[1:]], token))
			return 1 if re.match(state_regexes[state[1:]], token) else 0
		else:
			return emission_probs[next_state][token]
	best_candidate = None
	# 'candidates' are (log_prob, intent, [state]) tuples
	tokens = tokenize(text, preserve_regexes = state_regexes.values())
	for intent in intents:
		# print 'INTENT {0}'.format(intent)
		candidates = [(0.0, intent, ['$START_{0}'.format(intent)])]
		for token in tokens + [None]:
			# if intent == 'search': print candidates
			best_candidates_for_last_state = {}
			for (candidate_log_prob, candidate_intent, candidate_states) in candidates:
				state = candidate_states[-1].split('/')[0]
				for next_state_root, transition_prob in transition_probs[state].iteritems():
					new_candidate = None
					if token == None: 
						if next_state_root == "$END_{0}".format(intent):
							# print state, next_state_root, transition_prob
							new_candidate = (candidate_log_prob + smooth_log_prob(transition_prob), candidate_intent, candidate_states)
							if next_state_root not in best_candidates_for_last_state or new_candidate[0] > best_candidates_for_last_state[next_state_root][0]:
								best_candidates_for_last_state[next_state_root] = new_candidate
					else:
						for next_state in states_for_root_states[next_state_root]:
							if next_state[0]=='[':
								state_intent = next_state.split(':')[0][1:]
								if state_intent != intent:
									continue
							emission_prob = get_emission_prob(next_state, token)
							new_candidate = (candidate_log_prob + smooth_log_prob(transition_prob) + smooth_log_prob(emission_prob), candidate_intent, candidate_states + [next_state])
							if next_state not in best_candidates_for_last_state or new_candidate[0] > best_candidates_for_last_state[next_state][0]:
								best_candidates_for_last_state[next_state] = new_candidate
			candidates = best_candidates_for_last_state.values()
		#print candidates
		for candidate in candidates:
			if best_candidate == None or candidate[0] > best_candidate[0]:
				best_candidate = candidate
	return phrase_from_candidate(best_candidate, tokens) if best_candidate else None

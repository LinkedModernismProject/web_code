# coding: utf-8

"""
Basic queries for nl2sparql quepy.
"""

from dsl import *
from refo import Group, Plus, Question
from quepy.parsing import Lemma, Pos, QuestionTemplate, Token, Particle, \
                          Lemmas

# Openings
LISTOPEN = Lemma("list") | Lemma("name")

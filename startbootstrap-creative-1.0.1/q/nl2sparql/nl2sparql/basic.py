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

class Thing(Particle):
    regex = Question(Pos("JJ")) + (Pos("NN") | Pos("NNP") | Pos("NNS")) |\
            Pos("VBN")

    def interpret(self, match):
        return HasKeyword(match.words.tokens)



class RelatedTo(QuestionTemplate):
    """
    Ex. Person related to thing
        Thing related to Place
    """


    regex = Lemma("show")

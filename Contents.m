% KNOCK CONTROL
%
% Engine / Knock Characterization
%   eCdf       - eCdf Empirical cumulative distribution function for a cell array of spark sweep experiments
%   normCdf    - nCdf Normalize cumulative density function data
%   p2x        - p2x Evaluate/look-up inverse empirical cumulative density function F^-1(p)
%   x2p        - x2p Evaluate/look-up empirical cumulative density function p=F(x)
%   optTx      - optTx Computes optimized knock thresholds
%   knockP     - knockP Computes knock probability curves
%
% Stochastic Simulation - Traditional Controller
%   markovMx   - markovMx Construct state transition matrices for a traditional knock controller
%   pdfSpk     - pdfSpk Probability density function of closed-loop relative spark advance
%   pdfKnk     - pdfKnk Distribution of number of knock events in first n cycles
%   mKnk       - mKnk Mean (closed-loop) number of knock events in first n cycles
%   mSpk       - mSpk Mean closed-loop spark angle, time-averaged over the first n cycles
%   respT      - respT Transient response statistics for a traditional knock controller
%   compress   - Deals with repeated values in pdfPoints and hence in pdf
%
% Demo / Example
%   demo       - 

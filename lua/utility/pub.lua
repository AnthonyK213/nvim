local M = {}
local core_opt = require('core/opt')


if vim.fn.has("win32") == 1 then
    M.start = 'start'
    M.shell = core_opt.dep.sh or 'powershell.exe -nologo'
    M.ccomp = core_opt.dep.cc or 'gcc'
elseif vim.fn.has("unix") == 1 then
    M.start = 'xdg-open'
    M.shell = core_opt.dep.sh or 'bash'
    M.ccomp = core_opt.dep.cc or 'gcc'
elseif vim.fn.has("mac") == 1 then
    M.start = 'open'
    M.shell = core_opt.dep.sh or 'zsh'
    M.ccomp = core_opt.dep.cc or 'clang'
end

-- URL utilities.
M.esc_url = {
    [" "]  = "\\%20", ["!"]  = "\\%21", ['"']  = "\\%22",
    ["#"]  = "\\%23", ["$"]  = "\\%24", ["%"]  = "\\%25",
    ["&"]  = "\\%26", ["'"]  = "\\%27", ["("]  = "\\%28",
    [")"]  = "\\%29", ["*"]  = "\\%2A", ["+"]  = "\\%2B",
    [","]  = "\\%2C", ["/"]  = "\\%2F", [":"]  = "\\%3A",
    [";"]  = "\\%3B", ["<"]  = "\\%3C", ["="]  = "\\%3D",
    [">"]  = "\\%3E", ["?"]  = "\\%3F", ["@"]  = "\\%40",
    ["\\"] = "\\%5C", ["|"]  = "\\%7C", ["\n"] = "\\%20",
    ["\r"] = "\\%20", ["\t"] = "\\%20"
}

local url_domains =
[[.ac.ad.ae.aero.af.ag.ai.al.am.an.ao.aq.ar.arpa.as.asia.at.au.aw.ax.az
.ba.bb.bd.be.bf.bg.bh.bi.biz.bj.bm.bn.bo.br.bs.bt.bv.bw.by.bz
.ca.cat.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.com.coop.cr.cs.cu.cv.cx.cy.cz
.dd.de.dj.dk.dm.do.dz
.ec.edu.ee.eg.eh.er.es.et.eu
.fi.firm.fj.fk.fm.fo.fr.fx
.ga.gb.gd.ge.gf.gh.gi.gl.gm.gn.gov.gp.gq.gr.gs.gt.gu.gw.gy
.hk.hm.hn.hr.ht.hu
.id.ie.il.im.in.info.int.io.iq.ir.is.it
.je.jm.jo.jobs.jp
.ke.kg.kh.ki.km.kn.kp.kr.kw.ky.kz
.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly
.ma.mc.md.me.mg.mh.mil.mk.ml.mm.mn.mo.mobi.mp.mq.mr.ms.mt.mu.museum.mv.mw.mx.my.mz
.na.name.nato.nc.ne.net.nf.ng.ni.nl.no.nom.np.nr.nt.nu.nz
.om.org
.pa.pe.pf.pg.ph.pk.pl.pm.pn.post.pr.pro.ps.pt.pw.py
.qa
.re.ro.ru.rw
.sa.sb.sc.sd.se.sg.sh.si.sj.sk.sl.sm.sn.so.sr.ss.st.store.su.sv.sy.sz
.tc.td.tel.tf.tg.th.tj.tk.tl.tm.tn.to.tp.tr.travel.tt.tv.tw.tz
.ua.ug.uk.um.us.uy
.va.vc.ve.vg.vi.vn.vu
.web.wf.ws
.xxx
.ye.yt.yu
.za.zm.zr.zw]]

M.url_domain_table = {}
for domain in url_domains:gmatch('%w+') do
    M.url_domain_table[domain] = true
end

-- Boxes
--[[
┌─┐┍━┑┎─┒┏━┓╭─╮╒═╕╓─╖╔═╗
│ ││ │┃ ┃┃ ┃│ ││ │║ ║║ ║
└─┘┕━┙┖─┚┗━┛╰─╯╘═╛╙─╜╚═╝
]]


return M

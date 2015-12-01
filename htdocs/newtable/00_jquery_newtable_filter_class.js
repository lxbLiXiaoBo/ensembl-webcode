/*
 * Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

(function($) {
  function update_counts($el,state,values) {
    var m = 0;
    var n = 0;
    $.each(values,function(i,val) {
      n++;
      if(!state[val]) { m++; }
    });
    $el.text('('+m+'/'+n+' on)');
    $el.closest('.m').trigger('okable',[m?true:false]);
  }

  function click($el,$body,type,bkey,km,$summary,values) {
    var state = {};
    $body.children('ul').children('li').each(function() {
      var $this = $(this);
      var key = $this.data('key');
      var baked = (((km||{})[key]||{}).baked)||[];
      var ok = false;
      if(type=='bakery') {
        for(var i=0;i<baked.length;i++) {
          if(baked[i]==bkey) { ok = true; }
        }
      } else if(type=='all') {
        if(bkey===true) { ok = true; }
        if(bkey===false) { ok = false; }
      } else { // type == 'one'
        ok = $this.hasClass('on');
        if(key==bkey) { ok = !ok; }
      }
      if(ok) {
        $this.addClass('on');
      } else {
        state[key] = 1;
        $this.removeClass('on');
      }
    });
    $el.trigger('update',state);
    update_counts($summary,state,values);
  }

  function add_baked($baked,$body,$el,$summary,values,key,km) {
    var all = [];
    var $alloff = $('<li/>').text('Turn All Off');
    all.push($alloff);
    $alloff.click(function() {
      click($el,$body,'all',false,km,$summary,values);
    });
    var bakery = (((km||{})['*']||{}).bakery)||[];
    for(var i=0;i<bakery.length;i++) {
      var $bake = $('<li/>').text(bakery[i].label);
      all.push($bake);
      (function(j) {
        $bake.click(function() {
          click($el,$body,'bakery',bakery[j].key,km,$summary,values);
        });
      })(i);
    }
    var $allon = $('<li/>').addClass('allon').text('Turn All On');
    all.push($allon);
    $allon.click(function() {
      click($el,$body,'all',true,km,$summary,values);
    });
    var $buttons = $('<ul/>').addClass('bakery').appendTo($baked);
    all[0].addClass('first');
    all[all.length-1].addClass('last');
    if(all.length>2) { all[all.length-1].addClass('last_of_many'); }
    for(var i=0;i<all.length;i++) { $buttons.append(all[i]); }
  }

  function add_bakefoot($bakefoot,km) {
    var bakefoot = (((km||{})['*']||{}).bakefoot)||[];
    if(!bakefoot.length) { return; }
    var $ul = $('<ul/>').appendTo($bakefoot);
    for(var i=0;i<bakefoot.length;i++) {
      var $li = $('<li/>').appendTo($ul).html(bakefoot[i]);
    }
  }

  $.fn.newtable_filter_class = function(config,data) {
    return {
      filters: [{
        name: "class",
        display: function($box,$el,enums,state,km,key,$table) {
          var cc = config.colconf[key];
          var title = (cc.filter_label || cc.label || cc.title || key);
          var $summary = $('.summary_text',$box).text('(x/y on)');
          var $baked = $('<div class="baked"/>').appendTo($box);
          var $bakefoot = $('<div class="bakefoot"/>').appendTo($box);
          var $body = $('<div class="body"/>').appendTo($box);
          var counts = enums.counts;
          var values = enums.keys.slice();
          add_baked($baked,$body,$el,$summary,values,key,km);
          add_bakefoot($bakefoot,km);
          if(!cc.filter_sorted) {
            values.sort(function(a,b) { return a.localeCompare(b); });
          }
          var $ul;
          var splits = [0];
          if(values.length > 4) {
            splits = [0,values.length/3,2*values.length/3];
            $body.addClass('use_cols');
          }
          /* Blank always goes at the end */
          var bidx = values.indexOf('');
          if(bidx!==-1) {
            values.splice(bidx,1);
            values.push('');
          }
          $.each(values,function(i,val) {
            if(i>=splits[0]) {
              $ul = $("<ul/>").appendTo($body);
              splits.shift();
            }
            var $li = $("<li/>").data('key',val).appendTo($ul);
            var count = counts[val];
            var $li_more = $('<div/>').text("("+count+")").addClass('more').appendTo($li);
            var $li_main = $('<div/>').addClass('main').appendTo($li);
            $table.trigger('paint-individual',[$li_main,key,val]);
            $li.data('val',val);
            if(!state[val]) { $li.addClass("on"); }
            $li.on('click',function() {
              click($el,$body,'one',val,km,$summary,values);
            });
          });
          update_counts($summary,state,values);
        },
        text: function(state,all) {
          var skipping = {};
          $.each(state,function(k,v) { skipping[k]=1; });
          var on = [];
          var off = [];
          $.each(all.keys,function(i,v) {
            var vout = (v===''?'blank':v);
            if(skipping[v]) { off.push(vout); } else { on.push(vout); }
          });
          var out = "None";
          if(on.length<=off.length) {
            out = on.join(', ');
          } else if(on.length) {
            out = 'All except '+off.join(', ');
          }
          if(out.length>20) {
            out = out.substr(0,20)+'...('+on.length+'/'+all.keys.length+')';
          }
          return out;
        },
        visible: function(values) {
          return values && values.keys && !!values.keys.length;
        }
      }]
    };
  };
})(jQuery);

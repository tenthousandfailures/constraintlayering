package layer;

`include "uvm_macros.svh"
    import uvm_pkg::*;

    typedef enum {READ, WRITE} rw_t;
    // NOT IN PAPER BUT NEEDED
    typedef bit [31:0] addr_t;
       
class policy_base#(type ITEM=uvm_object);
    ITEM item;

    virtual      function void set_item(ITEM item);
        this.item = item;
    endfunction
    
endclass

class addr_txn;
    rand bit [31:0] addr;
    rand int size;
    rand policy_base#(addr_txn) policy[$];

    constraint c_size { size inside {1,2,4}; }

    function void pre_randomize;
        foreach(policy[i]) policy[i].set_item(this);
    endfunction

endclass
    
class rw_txn extends addr_txn;
    rand rw_t op;

    function void rprint();
        this.randomize();
        this.print();        
    endfunction

    function void print();
        $display("  addr=%h size=%0d", this.addr, this.size);
    endfunction
    
endclass
    
class policy_list#(type ITEM=uvm_object) extends policy_base #(ITEM);
    rand policy_base#(ITEM) policy[$];

    function void add(policy_base#(ITEM) pcy);
        policy.push_back(pcy);
    endfunction

    function void set_item(ITEM item);
        foreach(policy[i]) policy[i].set_item(item);
    endfunction
    
endclass

// NOT IN PAPER BUT NEEDED
class addr_range;
    addr_t          min;
    addr_t          max;
        
    function new(addr_t min=0, addr_t max=0);
        this.min = min;
        this.max = max;
    endfunction
    
endclass
    
class addr_policy_base extends policy_base#(addr_txn);
    addr_range ranges [$];

    function add(addr_t min, addr_t max);
        addr_range rng = new(min, max);
        ranges.push_back(rng);
    endfunction
endclass

class addr_permit_policy extends addr_policy_base;
    rand int selection;

    constraint c_addr_permit {
        // needed
        selection inside {[0 : ranges.size() - 1]};

        foreach(ranges[i]) {
            if(selection == i) {
                item.addr inside {[ranges[i].min: ranges[i].max - item.size]};
            }
        }
    }
endclass

class addr_prohibit_policy extends addr_policy_base;
    constraint c_addr_prohibit {
        foreach(ranges[i]) {
            !(item.addr inside {[ranges[i].min : 1 + ranges[i].max - item.size]});
        }
    }
endclass


class cache_evict_policy extends addr_policy_base;
    addr_t line_hist[$];
    int          index;

    function new;
        super.new();
        std::randomize(index) with {index inside {[0:'h3f]}; };

    endfunction

    constraint c_evict {
        !((item.addr & 'hFFFFF000) inside {this.line_hist}); // different tag
        (item.addr & 'h00000FC0) == (this.index << 6);       // same index
    }

    function void post_randomize;
        line_hist.push_back(item.addr & 'hFFFFF000);
    endfunction
    
endclass
    
class rw_constrained_txn extends rw_txn;
    function new;
        addr_permit_policy permit = new;
        addr_prohibit_policy prohibit = new;
        cache_evict_policy evict = new;
                
        policy_list#(addr_txn) pcy = new;

        permit.add('h00000000, 'h0000FFFF);
        permit.add('h10000000, 'h1FFFFFFF);
        pcy.add(permit);

        prohibit.add('h13000000, 'h130FFFFF);
        pcy.add(prohibit);
        pcy.add(evict);
                
        this.policy = {pcy};
        
    endfunction

endclass
    
endpackage    

module TB ();

    import layer::*;
    layer::rw_constrained_txn rw_constrained_txn;
    
    initial begin
        rw_constrained_txn = new;
        
        $display("\nFIGURE 11. Cache evict policy using state variable set in post_randomize:");
        for (int i = 0; i < 5; i++) begin
            rw_constrained_txn.rprint();
        end
        
    end
   
endmodule
